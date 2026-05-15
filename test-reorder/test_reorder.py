from collections import defaultdict

from xdsl.backend.riscv.lowering import convert_arith_to_riscv, convert_func_to_riscv_func
from xdsl.backend.register_allocatable import RegisterAllocatableOperation

from xdsl.transforms import reconcile_unrealized_casts
from xdsl.context import Context
from xdsl.dialects.builtin import ModuleOp, IndexType
from xdsl.dialects import arith, func, builtin, test, riscv, riscv_func, rv32
from xdsl.ir import Block, OpResult, Operation, Region, SSAValue
from xdsl.passes import PassPipeline
from xdsl.transforms import riscv_allocate_registers, riscv_allocate_infinite_registers, test_riscv_spilling, riscv_legalize_parallel_mov, riscv_reorder_infinite, riscv_lower_parallel_mov
from xdsl.backend.riscv.register_stack import RiscvRegisterStack
from xdsl.backend.register_stack import OutOfRegisters
from xdsl.utils.exceptions import PassFailedException
from xdsl.rewriter import Rewriter

import random

# PREALLOC:
def create_pmovs(N, init_regs = False) -> ModuleOp:
    random.seed(0)
    rstack = RiscvRegisterStack.get()
    vals = test.TestOp(result_types=[
        (riscv.Registers.UNALLOCATED_FLOAT if not init_regs else rstack.pop(riscv.FloatRegisterType)) for _ in range(N)
    ])
    a = vals.results[0]
    pmovs = []
    for _ in range(N):
        pmovs.append(riscv.ParallelMovOp([a], [riscv.Registers.UNALLOCATED_FLOAT], builtin.DenseArrayBase.from_list(builtin.i32, [32])))
        a = pmovs[-1].outputs[0]

    module = ModuleOp(
        [riscv_func.FuncOp(
            "func",
            Region(Block([vals, *pmovs, riscv_func.ReturnOp(*vals.results)])),
            ((), tuple(riscv.Registers.UNALLOCATED_FLOAT for _ in range(N)))
        )]
    )
    module.verify()

    riscv_legalize_parallel_mov.RISCVLegalizeParallelMovPass().apply(None, module)
    for op in module.walk():
        if isinstance(op, riscv.ParallelMovOp):
            r = list(op.inputs)
            random.shuffle(r)
            Rewriter.replace_op(
                op,
                riscv.ParallelMovOp(
                    r,
                    op.outputs.types,
                    op.input_widths,
                    op.free_registers,
                )
            )
    module.verify()
    return module

def preallocate_module(p, module: ModuleOp):
    random.seed(0)
    def can_alloc(val: OpResult, reg: riscv.FloatRegisterType):
        if reg in val.op.result_types:
            return False
        return True

    # randomly select some regs to set to prealloc values
    regs = [i for i in RiscvRegisterStack.default_allocatable_registers() if isinstance(i, riscv.FloatRegisterType)]
    for op in module.walk():
        for result in op.results:
            if random.random() < p:
                for _ in range(20):
                    if can_alloc(result, r:=random.choice(regs)):
                        Rewriter.replace_value_with_new_type(
                            result, r
                        )
                        break
                else:print("FAILED TO ALLOC")
    module.verify()


def regalloc_pipeline(module, reorder: bool):
    riscv_allocate_registers.RISCVAllocateRegistersPass(force_infinite=True).apply(None, module)
    if reorder:
        riscv_reorder_infinite.RISCVReorderInfinitePass().apply(None, module)
    riscv_allocate_infinite_registers.RISCVAllocateInfiniteRegistersPass().apply(None, module)
    riscv_lower_parallel_mov.RISCVLowerParallelMovPass().apply(None, module)
    module.verify()

N = 8
data = defaultdict(list)
for i in range(1, 50):
    module = create_pmovs(N)
    preallocate_module(i/100, module)
    try:
        regalloc_pipeline(module, False)
        c=0
        for op in module.walk():
            if isinstance(op, riscv.FMVOp):
                c += 1
        data["ifalse"].append(i)
        data[False].append(c)
    except OutOfRegisters:
        pass

for i in range(1, 50):
    module = create_pmovs(N)
    preallocate_module(i/100, module)
    try:
        regalloc_pipeline(module, True)
        c=0
        for op in module.walk():
            if isinstance(op, riscv.FMVOp):
                c += 1
        data["itrue"].append(i)
        data[True].append(c)
    except OutOfRegisters:
        pass

import matplotlib.pyplot as plt
plt.plot(data["ifalse"], data[False], label="No reordering")
plt.plot(data["itrue"], data[True], label="Reordering")
plt.xlabel("percentage of preallocated registers")
plt.ylabel("Move ops generated")
plt.title("Move ops generated against percentage of preallocated registers in input", wrap=True)
# Enable minor ticks to allow for a finer grid
plt.minorticks_on()
plt.legend()
plt.gca().set_ylim(bottom=0)
plt.gca().set_xlim(left=0)
plt.gca().spines['top'].set_visible(False)
plt.gca().spines['right'].set_visible(False)
# Customize the major grid (the primary lines)
plt.grid(visible=True, which='major', color='#666666', linestyle='-', alpha=0.6)

plt.savefig("build/test-reorder.svg")
