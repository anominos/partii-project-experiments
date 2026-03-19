from xdsl.dialects import riscv
from xdsl.dialects.test import TestOp
from xdsl.dialects.riscv.registers import Registers as R
from xdsl.dialects.riscv.ops import AddOp
from xdsl.dialects.builtin import ModuleOp, ArrayAttr, Operation, SSAValue, Attribute, Region, Block
from xdsl.dialects.riscv_func import FuncOp, ReturnOp

from xdsl.backend.register_stack import OutOfRegisters
from xdsl.backend.riscv.register_stack import RiscvRegisterStack
from xdsl.transforms import riscv_allocate_registers, riscv_allocate_infinite_registers
from xdsl.passes import PassPipeline

inps = [R.UNALLOCATED_INT for _ in range(5)]
free_reg = (R.T0, R.T1, R.T2, R.T3)

l: list[Operation] = []
for x in inps:
    l.append(TestOp(result_types=[x]))
vals = l[:]

l.append(AddOp(vals[0], vals[1]))
for x in vals[2:]:
    l.append(AddOp(l[-1], x))


l.append(AddOp(vals[1], vals[1]))

l.append(ReturnOp())

moduleop = ModuleOp([FuncOp("main", l, ([], []))])
print(moduleop)
RiscvRegisterStack.DEFAULT_ALLOCATABLE_REGISTERS = free_reg

riscv_allocate_registers.RISCVAllocateRegistersPass(force_infinite=True).apply(None, moduleop)

riscv_allocate_infinite_registers.RISCVAllocateInfiniteRegistersPass().apply(None, moduleop)
print(moduleop)
print()
riscv_allocate_infinite_registers.ResolveVirtualRegisters().apply(None, moduleop)
print(moduleop)

"""
t0, t1, t2, t3


%0 = t0
%1 = t1
%2 = t2

%3 = t3
sw %3 4(sp) : t3

%4 = t3

%5 = add %0 %1 (t0, t1) -> t0
%6 = add %5 %2 (t0 t2) -> t0



----------
r1=a,r2=b,r3=c,
f(a, b, c) = x

"""