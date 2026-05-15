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

import os

# PREALLOC:
def create_pmovs(N, init_regs = False) -> ModuleOp:
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
    module.verify()
    return module

def preallocate_module(p, module: ModuleOp):
    import random
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


def regalloc_pipeline(module):
    riscv_allocate_registers.RISCVAllocateRegistersPass(force_infinite=True).apply(None, module)
    riscv_allocate_infinite_registers.RISCVAllocateInfiniteRegistersPass().apply(None, module)
    module.verify()

N = 8
data = defaultdict(list)
for i in range(1, 90):
    module = create_pmovs(N)
    preallocate_module(i/100, module)
    try:
        regalloc_pipeline(module)
        rs = set()
        for op in module.walk():
            if isinstance(op, test.TestOp):
                for r in op.result_types:
                    rs.add(r)
            elif isinstance(op, riscv.ParallelMovOp):
                for r in op.operand_types:
                    rs.add(r)
                for r in op.result_types:
                    rs.add(r)
        data["p1"].append(i)
        data["exclude"].append(len(rs))
    except OutOfRegisters:
        pass

    module2 = create_pmovs(N)
    preallocate_module(i/100, module2)
    # riscv_lower_parallel_mov.RISCVLowerParallelMovPass().apply(None, module2)
    try:
        riscv_allocate_registers.RISCVAllocateRegistersPass().apply(None, module2)
        rs = set()
        for op in module2.walk():
            if isinstance(op, test.TestOp):
                for r in op.result_types:
                    rs.add(r)
            elif isinstance(op, riscv.ParallelMovOp):
                for r in op.operand_types:
                    rs.add(r)
                for r in op.result_types:
                    rs.add(r)
        data["p2"].append(i)
        data["noexclude"].append(len(rs))
    except OutOfRegisters:
        pass


import matplotlib.pyplot as plt
plt.plot(data["p1"], data["exclude"], label="Reuse")
plt.plot(data["p2"], data["noexclude"], label="No reuse")
plt.xlabel("Percentage of preallocated registers")
plt.ylabel("Registers used")
plt.title("Registers used against percentage of preallocated registers in input", wrap=True)
# Enable minor ticks to allow for a finer grid
plt.minorticks_on()
plt.legend()

# Customize the major grid (the primary lines)
plt.grid(visible=True, which='major', color='#666666', linestyle='-', alpha=0.6)

plt.savefig("build/test-prealloc.svg")
