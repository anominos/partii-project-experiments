from xdsl.dialects.arith import AddfOp, ConstantOp, FloatAttr, Float32Type, Float64Type
from xdsl.dialects.builtin import ModuleOp
from xdsl.dialects import riscv
from xdsl.backend.riscv.lowering import convert_arith_to_riscv
from xdsl.passes import PassPipeline
from xdsl.transforms import reconcile_unrealized_casts


a = ConstantOp(FloatAttr(0.1, Float32Type()))
b = ConstantOp(FloatAttr(0.2, Float32Type()))
c = AddfOp(a, b)
l = [a, b, c]
l.append(riscv.ParallelMovOp([i.result for i in [a, b, c]], [riscv.FloatRegisterType.unallocated(), riscv.FloatRegisterType.unallocated(), riscv.FloatRegisterType.unallocated()]))
module = ModuleOp(l)

passes = PassPipeline(
    (
        convert_arith_to_riscv.ConvertArithToRiscvPass(),
        reconcile_unrealized_casts.ReconcileUnrealizedCastsPass(),
    )
)

passes.apply(None, module)

print(module)