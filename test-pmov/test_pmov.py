from xdsl.backend.riscv.lowering import convert_arith_to_riscv, convert_func_to_riscv_func
from xdsl.backend.register_allocatable import RegisterAllocatableOperation

from xdsl.transforms import reconcile_unrealized_casts
from xdsl.context import Context
from xdsl.dialects.builtin import ModuleOp, IndexType
from xdsl.dialects import arith, func, builtin, test, riscv, riscv_func, rv32
from xdsl.ir import Block, Operation, Region
from xdsl.passes import PassPipeline
from xdsl.transforms import riscv_allocate_registers, riscv_allocate_infinite_registers, test_riscv_spilling, riscv_legalize_parallel_mov, riscv_reorder_infinite, riscv_lower_parallel_mov
from xdsl.backend.riscv.register_stack import RiscvRegisterStack
from xdsl.backend.register_stack import OutOfRegisters
from xdsl.utils.exceptions import PassFailedException

import os

def create_swaps_pmov(n: int) -> ModuleOp:
    register_stack = RiscvRegisterStack.get()
    regs = [register_stack.pop(riscv.FloatRegisterType) for _ in range(n)]
    create_vals = test.TestOp((), regs)
    pmov_op_1 = riscv.ParallelMovOp(
        create_vals.results,
        [riscv.Registers.UNALLOCATED_FLOAT for _ in range(n)],
        builtin.DenseArrayBase.from_list(builtin.i32, [32]*n),
    )
    pmov_op_2 = riscv.ParallelMovOp(
        pmov_op_1.results,
        regs[1:] + regs[:1],
        builtin.DenseArrayBase.from_list(builtin.i32, [32]*n),
    )
    return_op = riscv_func.ReturnOp(*pmov_op_2.outputs)
    block = Block((create_vals, pmov_op_1, pmov_op_2, return_op))
    region = Region(block)

    func = riscv_func.FuncOp("func", region, ([], regs[1:] + regs[:1]))

    return ModuleOp([func,])

def create_swaps_sequential(n: int) -> ModuleOp:
    register_stack = RiscvRegisterStack.get()
    regs = [register_stack.pop(riscv.FloatRegisterType) for _ in range(n)]
    create_vals = test.TestOp((), regs)
    movs_1 = [
        riscv.FMVOp(i) for i in create_vals.results
    ]
    movs_2 = [
        riscv.FMVOp(i.rd, rd=j) for i, j in zip(
            movs_1,
            regs[1:] + regs[:1],
        )
    ]
    return_op = riscv_func.ReturnOp(*movs_2)
    block = Block((create_vals, *movs_1, *movs_2, return_op))
    region = Region(block)

    func = riscv_func.FuncOp("func", region, ([], regs[1:] + regs[:1]))

    return ModuleOp([func,])

def pipeline(n, parallel_move=True):
    if parallel_move:
        module = create_swaps_pmov(n)
    else:
        module = create_swaps_sequential(n)

    ctx = Context()
    riscv_legalize_parallel_mov.RISCVLegalizeParallelMovPass().apply(ctx, module)
    riscv_allocate_registers.RISCVAllocateRegistersPass(force_infinite=True).apply(ctx, module)
    riscv_reorder_infinite.RISCVReorderInfinitePass().apply(ctx, module)
    riscv_allocate_infinite_registers.RISCVAllocateInfiniteRegistersPass().apply(ctx, module)
    riscv_lower_parallel_mov.RISCVLowerParallelMovPass().apply(ctx, module)

    return module

def main():
    from matplotlib import pyplot as plt
    data = {}
    for use_pmov in (False, True):
        ns, num_regs = [], []
        for n in range(1, 40):
            try:
                module = pipeline(n, use_pmov)
            except (PassFailedException, OutOfRegisters):
                break
            used_regs = RegisterAllocatableOperation.iter_all_used_registers(
                module.body
            )
            num_moves = 0
            for op in module.walk():
                if isinstance(op, riscv.FMVOp):
                    num_moves += 1

            ns.append(n)
            num_regs.append(len(set(used_regs)))

        data[use_pmov] = ns, num_regs

    plt.plot(data[False][0], data[False][1], label="Sequential Moves", marker="o")
    plt.plot(data[True][0], data[True][1], label="Parallel Moves", marker="x")
    plt.xlabel("Number of values being moved")
    plt.ylabel("Unique registers used")
    plt.title("Register usage using sequential and parallel moves")
    plt.legend()
    # Enable minor ticks to allow for a finer grid
    plt.minorticks_on()
    plt.gca().set_ylim(bottom=0)
    plt.gca().set_xlim(left=0)
    plt.gca().spines['top'].set_visible(False)
    plt.gca().spines['right'].set_visible(False)
    # Customize the major grid (the primary lines)
    plt.grid(visible=True, which='major', color='#666666', linestyle='-', alpha=0.6)

    plt.savefig("build/test-pmov-graph.svg")

if __name__ == "__main__":
    main()
