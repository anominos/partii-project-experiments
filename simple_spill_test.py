from xdsl.dialects import riscv, rv32
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
from xdsl.ir import Region, Block
from xdsl.dialects.builtin import ModuleOp, i32
from xdsl.dialects import riscv
from xdsl.context import Context

ctx = Context()
ctx.load_dialect(riscv.RISCV)

free_reg = (R.T0, R.T1, R.T2)

l: list[Operation] = []
# t_op = TestOp(result_types=[R.UNALLOCATED_INT] * 3)
# a, b, c = t_op.results
# l.append(t_op)
# l.append((d:=AddOp(a, b)))
# l.append((e:=AddOp(c, d)))
# l.append((f:=AddOp(a, b)))
# l.append(ReturnOp())

# moduleop = ModuleOp([FuncOp("main", l, ([], []))])
val_a = rv32.LiOp(1, comment="Var A")
val_b = rv32.LiOp(2, comment="Var B - Furthest Use")
val_c = rv32.LiOp(3, comment="Var C")

use_a = riscv.AddOp(val_a, val_a, comment="Immediate use of A")

# Use Var C soon
filler = rv32.LiOp(10, rd=R.ZERO, comment="Filler to increase distance")
use_c = riscv.AddOp(val_c, val_c, comment="Next use is C")

# Use Var B much later
padding = [riscv.AddOp(filler, filler, rd=R.ZERO) for _ in range(5)]
use_b = riscv.AddOp(val_b, val_b, comment="Furthest use is B")
l=[
    val_a, val_b, val_c, d:=rv32.LiOp(3, comment="Var D"),
    use_a,
    use_c,
    use_b,
    ReturnOp(use_a, use_b, use_c, d),
]
moduleop = ModuleOp([FuncOp("main", l, ([], []))])
print(moduleop)
RiscvRegisterStack.DEFAULT_ALLOCATABLE_REGISTERS = free_reg


test_riscv_spilling.SpillPass().apply(None, moduleop)
# test_riscv_spilling.ResolveSpillingOps().apply(None, moduleop)
print(moduleop)

# ConvertRiscvStackToRiscvPass().apply(None, moduleop)
# ConvertMemRefToRiscvPass().apply(None, moduleop)
# riscv_allocate_registers.RISCVAllocateRegistersPass().apply(None, moduleop)
# reconcile_unrealized_casts.ReconcileUnrealizedCastsPass().apply(None, moduleop)

"""
a,b,c = ....
d = a+b
e = c+d
f = a+b

"""