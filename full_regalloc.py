# Generate filecheck test for a parallel move
import sys
from collections.abc import Sequence
from xdsl.context import Context
from xdsl.dialects.builtin import ModuleOp, ArrayAttr, Operation, SSAValue, Attribute
from xdsl.dialects.riscv import RISCV, ParallelMovOp, CustomAssemblyInstructionOp, AddOp
from xdsl.dialects.riscv.ops import *
from xdsl.dialects.riscv_func import FuncOp, ReturnOp
from xdsl.ir import Block, Region
from xdsl.dialects.test import TestOp
from xdsl.backend.riscv.register_allocation import RegisterAllocatorLivenessBlockNaive
from xdsl.backend.riscv.register_stack import RiscvRegisterStack

from xdsl.dialects.riscv import Registers as R
from xdsl.transforms import riscv_lower_parallel_mov, riscv_allocate_registers
from xdsl.transforms import riscv_allocate_registers, riscv_allocate_infinite_registers, test_riscv_spilling
from xdsl.transforms import riscv_legalize_parallel_mov, riscv_reorder_infinite
# Initialize context and load dialects
ctx = Context()
ctx.load_dialect(RISCV)


l: list[Operation] = [
    # a, b, c = testop()
    TestOp([], [R.UNALLOCATED_FLOAT, R.UNALLOCATED_FLOAT, R.UNALLOCATED_FLOAT]),
]
a, b, c = l[0].results
l.append(d:=FAddSOp(a, b))
l.append(e:=ParallelMovOp([c], [R.UNALLOCATED_FLOAT], DenseArrayBase.from_list(i32, [32])))
l.append(f:=FAddSOp(d, e))
l.append(g:=ParallelMovOp([f.rd], [R.FT0], DenseArrayBase.from_list(i32, [32])))
l.append(ReturnOp(g, a))
"""
f(a, b, c):
d = a+b
e = c
f = d + e
g = f
return g, a

"""

l: list[Operation] = [
    # a, b, c = testop()
    TestOp([], [R.UNALLOCATED_FLOAT, R.UNALLOCATED_FLOAT, R.UNALLOCATED_FLOAT]),
]
a,b,c = l[0].results
l.append(d:=ParallelMovOp([c], [R.FT0], DenseArrayBase.from_list(i32, [32])))
l.append(ReturnOp(a, b, d))


block = Block(l)
region = Region(block)
main = FuncOp("main", region, ([], [R.UNALLOCATED_FLOAT, R.UNALLOCATED_FLOAT]))

module = ModuleOp([main])
module.verify()

# rstack = RiscvRegisterStack.get(free_reg)
# allocator = RegisterAllocatorLivenessBlockNaive(rstack)
# g.allocate_registers(allocator)
riscv_legalize_parallel_mov.RISCVLegalizeParallelMovPass().apply(None, module)
# print(module)
riscv_allocate_registers.RISCVAllocateRegistersPass(force_infinite=True).apply(None, module)
print(module)
riscv_reorder_infinite.RISCVReorderInfinitePass().apply(None, module)
print(module)


# riscv_allocate_infinite_registers.RISCVAllocateInfiniteRegistersPass().apply(None, module)
# riscv_lower_parallel_mov.RISCVLowerParallelMovPass().apply(None, module)

