# Generate filecheck test for a parallel move
import sys
from collections.abc import Sequence
from xdsl.context import Context
from xdsl.dialects.builtin import ModuleOp, ArrayAttr, Operation, SSAValue, Attribute
from xdsl.dialects.riscv import RISCV, ParallelMovOp, GetRegisterOp, CustomAssemblyInstructionOp, AddOp
from xdsl.dialects.riscv_func import FuncOp, ReturnOp
from xdsl.ir import Block, Region
from xdsl.dialects.test import TestOp
from xdsl.backend.riscv.register_allocation import RegisterAllocatorLivenessBlockNaive
from xdsl.backend.riscv.register_stack import RiscvRegisterStack

from xdsl.dialects.riscv import Registers as R
from xdsl.transforms import riscv_lower_parallel_mov, riscv_allocate_registers
# Initialize context and load dialects
ctx = Context()
ctx.load_dialect(RISCV)


inps = [R.UNALLOCATED_INT, R.UNALLOCATED_INT, R.UNALLOCATED_INT]
outs = [R.UNALLOCATED_INT, R.UNALLOCATED_INT, R.UNALLOCATED_INT]
free_reg = ArrayAttr([R.S9, R.S10,R.S11, R.FS10])
assert len(inps) == len(outs)

l: list[Operation] = [TestOp([], inps)]

# l.append(ParallelMovOp(
#     l[0].results,
#     outs,
#     free_registers=free_reg
# ))

l.append(AddOp(l[-1].results[0], l[-1].results[1]))

l.append(TestOp(l[-1].results, []))
l.append(ReturnOp())
block = Block(l)
region = Region(block)
main = FuncOp("main", region, ([], []))

module = ModuleOp([main])
module.verify()
print(module, file=sys.stderr)
print("-----ALLOCATING-----", file=sys.stderr)

# rstack = RiscvRegisterStack.get(free_reg)
# allocator = RegisterAllocatorLivenessBlockNaive(rstack)
# g.allocate_registers(allocator)
riscv_allocate_registers.RISCVAllocateRegistersPass().apply(None, module)
print("---END ALLOCATING---", file=sys.stderr)
print(module, file=sys.stderr)


# print("-----LOWERING-----", file=sys.stderr)
# riscv_lower_parallel_mov.RISCVLowerParallelMovPass().apply(None, module)
# print("---END LOWERING---", file=sys.stderr)

# print(module)
