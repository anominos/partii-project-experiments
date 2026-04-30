from xdsl.dialects import riscv
from xdsl.dialects.test import TestOp
from xdsl.dialects.riscv.registers import Registers as R
from xdsl.dialects.riscv.ops import AddOp
from xdsl.dialects.builtin import ModuleOp, ArrayAttr, Operation, SSAValue, Attribute, Region, Block
from xdsl.dialects.riscv_func import FuncOp, ReturnOp

from xdsl.backend.register_stack import OutOfRegisters
from xdsl.backend.riscv.register_stack import RiscvRegisterStack
from xdsl.transforms import test_riscv_spilling, convert_memref_to_ptr, convert_ptr_to_riscv, reconcile_unrealized_casts, riscv_allocate_registers
from xdsl.backend.riscv.lowering.convert_riscv_stack_to_riscv import ConvertRiscvStackToRiscvPass
from xdsl.backend.riscv.lowering.convert_memref_to_riscv import ConvertMemRefToRiscvPass
from xdsl.backend.riscv.prologue_epilogue_insertion import PrologueEpilogueInsertion
free_reg = (R.T0, R.T1, R.T2)

l: list[Operation] = []
t_op = TestOp(result_types=[R.UNALLOCATED_INT] * 3)
a, b, c = t_op.results
l.append(t_op)
l.append((d:=AddOp(a, b)))
l.append((e:=AddOp(c, d)))
l.append((f:=AddOp(a, b)))
l.append(ReturnOp())

moduleop = ModuleOp([FuncOp("main", l, ([], []))])
print(moduleop)
RiscvRegisterStack.DEFAULT_ALLOCATABLE_REGISTERS = free_reg


test_riscv_spilling.SpillPass().apply(None, moduleop)
# test_riscv_spilling.ResolveSpillingOps().apply(None, moduleop)
print(moduleop)

ConvertRiscvStackToRiscvPass().apply(None, moduleop)
# ConvertMemRefToRiscvPass().apply(None, moduleop)
# riscv_allocate_registers.RISCVAllocateRegistersPass().apply(None, moduleop)
# reconcile_unrealized_casts.ReconcileUnrealizedCastsPass().apply(None, moduleop)
print(moduleop)

"""
a,b,c = ....
d = a+b
e = c+d
f = a+b

"""