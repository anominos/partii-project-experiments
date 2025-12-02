from xdsl.backend.riscv.lowering import convert_arith_to_riscv, convert_func_to_riscv_func, convert_memref_to_riscv
from xdsl.transforms import reconcile_unrealized_casts
from xdsl.context import Context
from xdsl.dialects.builtin import ModuleOp, IndexType
from xdsl.dialects import arith, func
from xdsl.ir import Block, Region
from xdsl.passes import PassPipeline
from xdsl.transforms import riscv_allocate_registers


def generate_module(n: int) -> ModuleOp:
    extern_func = func.FuncOp("foo", ([], [IndexType()]), Region(), visibility="private")

    calls = [func.CallOp("foo", [], [IndexType()]) for _ in range(n)]
    calls.append(arith.AddiOp(calls[0], calls[1]))
    for i in range(n-2):
        calls.append(arith.AddiOp(calls[-1], calls[i+2]))

    calls.append(func.ReturnOp(calls[-1]))

    block = Block(calls)
    region = Region(block)

    pressure_func = func.FuncOp("reg_pressure", ([], [IndexType()]), region=region)

    return ModuleOp([extern_func, pressure_func])


def main():
    module = generate_module(16)
    with open("build/mlir/module.mlir", "w") as f:
        print(module, file=f)
    passes = PassPipeline(
        (
            convert_arith_to_riscv.ConvertArithToRiscvPass(),
            convert_func_to_riscv_func.ConvertFuncToRiscvFuncPass(),
            reconcile_unrealized_casts.ReconcileUnrealizedCastsPass(),
        )
    )
    ctx = Context()
    passes.apply(ctx, module)
    print(module)
    riscv_allocate_registers.RISCVAllocateRegistersPass().apply(ctx, module)
    print(module)


if __name__ == "__main__":
    main()

"""
extern int foo();

int high_pressure() {
    int a0 = foo();
    int a1 = foo();
    int a2 = foo();
    int a3 = foo();
    int a4 = foo();
    int a5 = foo();
    int a6 = foo();
    int a7 = foo();
    int a8 = foo();
    int a9 = foo();
    int a10 = foo();
    int a11 = foo();
    int a12 = foo();
    int a13 = foo();
    int a14 = foo();
    int a15 = foo();
    return a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10 + a11 + a12 + a13 + a14 + a15;
}
"""