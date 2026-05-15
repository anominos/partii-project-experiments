import random

from xdsl.backend.riscv.lowering import convert_arith_to_riscv, convert_func_to_riscv_func

from xdsl.transforms import reconcile_unrealized_casts
from xdsl.context import Context
from xdsl.dialects.builtin import ModuleOp, IndexType
from xdsl.dialects import arith, func, test, builtin, riscv, riscv_func, rv32
from xdsl.ir import Block, OpResult, Operation, Region
from xdsl.passes import PassPipeline
from xdsl.transforms import riscv_allocate_registers


def generate_module(num_ins: int, num_add_ops: int) -> ModuleOp:

    ops: list[Operation] = [
        reg:=rv32.GetRegisterOp(riscv.Registers.ZERO),
    ]
    values: list[OpResult] = []
    for v in range(num_ins):
        ops.append(
            op:=riscv.FLwOp(reg, 100)
        )
        values.append(op.rd)

    for _ in range(num_add_ops):
        # pick 2 values and add them together
        v1, v2 = random.choices(values, k=2)
        ops.append(add_op:=riscv.FAddSOp(v1, v2))
        values.append(add_op.rd)

    ops.append(riscv_func.ReturnOp())

    block = Block(ops)
    region = Region(block)

    f = riscv_func.FuncOp("main", region, ([], []))

    return ModuleOp([f])


random.seed(1)
module = generate_module(4, 100)
print(module)