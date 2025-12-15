# Generate filecheck test for a parallel move

from collections.abc import Sequence
from xdsl.context import Context
from xdsl.dialects.builtin import ModuleOp, ArrayAttr, Operation, SSAValue, Attribute
from xdsl.dialects.riscv import RISCV, ParallelMovOp, GetRegisterOp, CustomAssemblyInstructionOp
from xdsl.dialects.test import TestOp

from xdsl.dialects.riscv import Registers as R
from xdsl.transforms import riscv_lower_parallel_mov
# Initialize context and load dialects
ctx = Context()
ctx.load_dialect(RISCV)


inps = [R.S1, R.S2, R.S3]
outs = [R.S2, R.S3, R.S1]
free_reg = ArrayAttr([R.S10])
assert len(inps) == len(outs)

l: list[Operation] = [TestOp([], inps)]

l.append(ParallelMovOp(l[0].results, outs))

l.append(TestOp(l[-1].results, []))

module = ModuleOp(l)
module.verify()
print(module)

# print("-----LOWERING-----")
# riscv_lower_parallel_mov.RISCVLowerParallelMovPass().apply(None, module)
# print("---END LOWERING---")

# print(module)
