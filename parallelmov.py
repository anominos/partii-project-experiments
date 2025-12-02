# Basic example to swap two registers using ParallelMov

from xdsl.context import Context
from xdsl.dialects.builtin import ModuleOp, ArrayAttr
from xdsl.dialects.riscv import RISCV, ParallelMovOp, GetRegisterOp, Registers, IntRegisterType
from xdsl.transforms import riscv_lower_parallel_mov
# Initialize context and load dialects
ctx = Context()
ctx.load_dialect(RISCV)

# s1 = GetRegisterOp(Registers.S1)
# s2 =

module = ModuleOp([
    ParallelMovOp([GetRegisterOp(Registers.S1), GetRegisterOp(Registers.S2)], [Registers.S3, Registers.S4], ArrayAttr([Registers.S5]))  # first example below
])
module.verify()
# print(module)


# riscv_lower_parallel_mov.RISCVLowerParallelMovPass().apply(None, module)

# print(module)



"""
%2, %3 = mov %1, %0 : a0, a1 -> a2, a3

%2 = mv %1 : a0 -> a2
%3 = mv %0 : a1 -> a3



%2, %3 = mov %1, %0 : a0, a1 -> a0, a1

%2 = mv %1 : a0 -> a0
%2 = %1



%2, %3 = mov %1, %0 : a0, a1 -> a1, a0

%4 = mv %1 : a0 -> a2
%3 = mv %0 : a1 -> a0
%2 = mv %4 : a2 -> a1

"""