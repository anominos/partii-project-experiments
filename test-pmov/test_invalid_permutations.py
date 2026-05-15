from collections import defaultdict
from re import L

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

from itertools import permutations

def generate_permutations_pmov(n):
    stack = RiscvRegisterStack.get()
    src_regs = []
    for _ in range(n):
        src_regs.append(stack.pop(riscv.FloatRegisterType))

    dst_regs = src_regs[1:]  + [stack.pop(riscv.FloatRegisterType)]
    free_reg = stack.pop(riscv.FloatRegisterType)
    total_perms = 0
    num_mvs=0
    total_regs = 0
    for inps in permutations(src_regs):
        srcs = test.TestOp(result_types=inps)
        pmov = riscv.ParallelMovOp(
            srcs.results,
            dst_regs,
            builtin.DenseArrayBase.from_list(builtin.i32, [32]*n),
            free_registers=builtin.ArrayAttr([free_reg]),
        )

        module = ModuleOp((srcs, pmov, riscv_func.ReturnOp(*pmov.results)))
        riscv_lower_parallel_mov.RISCVLowerParallelMovPass().apply(None, module)
        for op in module.walk():
            if isinstance(op, riscv.FMVOp):
                num_mvs += 1
        total_perms += 1
        total_regs += len(set(RegisterAllocatableOperation.iter_all_used_registers(module.body)))

    return (n, num_mvs / total_perms, total_regs / total_perms - (n+1))



def generate_permutations_sequential(n):
    stack = RiscvRegisterStack.get()
    src_regs = []
    for _ in range(n):
        src_regs.append(stack.pop(riscv.FloatRegisterType))

    dst_regs = src_regs[1:]  + [stack.pop(riscv.FloatRegisterType)]
    free_regs = [stack.pop(riscv.FloatRegisterType) for i in range(n)]
    total_perms = 0
    num_mvs=0
    total_regs = 0
    for inps in permutations(src_regs):
        srcs = test.TestOp(result_types=inps)
        mv_outs = []
        mv_ins = []
        for i, j, k in zip(srcs.results, free_regs, dst_regs):
            if i.type!=k:
                mv_outs.append(v:=riscv.FMVOp(i, rd=j))
                mv_ins.append(riscv.FMVOp(v, rd=k))

        module = ModuleOp((srcs, *mv_outs, *mv_ins, riscv_func.ReturnOp(*(i.rd for i in mv_ins))))

        for op in module.walk():
            if isinstance(op, riscv.FMVOp):
                num_mvs += 1
        total_perms += 1
        total_regs += len(set(RegisterAllocatableOperation.iter_all_used_registers(module.body)))

    return (n, num_mvs / total_perms, total_regs / total_perms - (n+1))

data_pmov = defaultdict(list)
data_seq = defaultdict(list)
for x in range(1, 8):
    print(x)
    n, mvs, regs = generate_permutations_pmov(x)
    data_pmov["n"].append(n)
    data_pmov["mvs"].append(mvs)
    data_pmov["regs"].append(regs)
    n, mvs, regs = generate_permutations_sequential(x)
    data_seq["n"].append(n)
    data_seq["mvs"].append(mvs)
    data_seq["regs"].append(regs)
print("plotting")
from matplotlib import pyplot as plt
plt.plot(data_seq["n"], data_seq["mvs"], label="Sequential Moves", marker="x")
plt.plot(data_pmov["n"], data_pmov["mvs"], label="Parallel Moves", marker="o")
plt.xlabel("Number of values being moved")
plt.ylabel("Average moves generated")
plt.title("Moves used for reordering registers using sequential and parallel moves", wrap=True)
plt.legend()
# Enable minor ticks to allow for a finer grid
plt.minorticks_on()

# Customize the major grid (the primary lines)
plt.grid(visible=True, which='major', color='#666666', linestyle='-', alpha=0.6)

plt.savefig("build/test-perms-graph-mvs.svg")



plt.clf()
plt.plot(data_seq["n"], data_seq["regs"], label="Sequential Moves", marker="x")
plt.plot(data_pmov["n"], data_pmov["regs"], label="Parallel Moves", marker="o")
plt.xlabel("Number of values being moved")
plt.ylabel("Average extra registers used")
plt.title("Extra registers used for reordering registers using sequential and parallel moves", wrap=True)
plt.legend()
# Enable minor ticks to allow for a finer grid
plt.minorticks_on()

# Customize the major grid (the primary lines)
plt.grid(visible=True, which='major', color='#666666', linestyle='-', alpha=0.6)

plt.savefig("build/test-perms-graph-regs.svg")