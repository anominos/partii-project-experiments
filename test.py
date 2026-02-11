from xdsl.dialects import riscv
from xdsl.dialects.test import TestOp
from xdsl.dialects.riscv import Registers as R
from xdsl.dialects.builtin import ModuleOp, ArrayAttr, Operation, SSAValue, Attribute


# inps = [R.UNALLOCATED_INT, R.UNALLOCATED_INT, R.UNALLOCATED_INT]
# outs = [R.UNALLOCATED_INT, R.T0, R.UNALLOCATED_INT]
inps = [R.FT0, R.FT1, R.FT2]
outs = [R.FT3, R.FT4, R.FT5]
free_reg = ArrayAttr([R.S9, R.S10,R.S11, R.FS10])
assert len(inps) == len(outs)

l: list[Operation] = [TestOp([], inps)]

l.append(riscv.ParallelMovOp(
    l[0].results,
    outs,
    ArrayAttr([32, 32, 64])
    free_registers=free_reg
))
