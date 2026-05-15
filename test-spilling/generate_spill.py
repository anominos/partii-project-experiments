from xdsl.backend.riscv.lowering import convert_arith_to_riscv, convert_func_to_riscv_func
from xdsl.dialects.riscv import stack as riscv_stack
from xdsl.transforms import reconcile_unrealized_casts
from xdsl.context import Context
from xdsl.dialects.builtin import ModuleOp, IndexType
from xdsl.dialects import arith, func, builtin, test, riscv
from xdsl.ir import Block, Operation, Region
from xdsl.passes import PassPipeline
from xdsl.transforms import riscv_allocate_registers, riscv_allocate_infinite_registers, test_riscv_spilling, riscv_legalize_parallel_mov, riscv_reorder_infinite, riscv_lower_parallel_mov


def generate_module(n: int) -> ModuleOp:
    extern_func = func.FuncOp("foo", ([], [builtin.Float32Type()]), Region(), visibility="private")

    calls: list[Operation] = [func.CallOp("foo", [], [builtin.Float32Type()]) for _ in range(n)]
    # calls: list[Operation] = [test.TestOp(result_types = [builtin.Float32Type()]) for _ in range(n)]
    calls.append(arith.AddfOp(calls[-1], calls[-2]))
    for i in range(1,n-1):
        calls.append(arith.AddfOp(calls[-1], calls[n-i-2]))

    calls.append(func.ReturnOp(calls[-1]))

    block = Block(calls)
    region = Region(block)

    pressure_func = func.FuncOp("reg_pressure", ([], [builtin.Float32Type()]), region=region)

    return ModuleOp([extern_func, pressure_func])


def do_spill(n: int):
    module = generate_module(n)
    with open("build/arith-module.mlir", "w") as f:
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
    with open("build/riscv-module.mlir", "w") as f:
        print(module, file=f)

    test_riscv_spilling.TestRiscvSpillingPass().apply(ctx, module)

    with open("build/riscv-module-spilt.mlir", "w") as f:
        print(module, file=f)

    riscv_legalize_parallel_mov.RISCVLegalizeParallelMovPass().apply(ctx, module)
    riscv_allocate_registers.RISCVAllocateRegistersPass(force_infinite=True).apply(ctx, module)
    riscv_reorder_infinite.RISCVReorderInfinitePass().apply(ctx, module)
    riscv_allocate_infinite_registers.RISCVAllocateInfiniteRegistersPass().apply(ctx, module)

    riscv_lower_parallel_mov.RISCVLowerParallelMovPass().apply(ctx, module)
    # with open("build/riscv-module-allocated.mlir", "w") as f:
    #     print(module, file=f)
    return module

if __name__ == "__main__":
    ns = []
    mem_counts = []
    for i in range(3, 75):
        module = do_spill(i)
        mem_ops = 0
        for op in module.walk():
            if isinstance(op, (riscv_stack.LoadOp, riscv_stack.StoreOp)):
                mem_ops += 1

        ns.append(i)
        mem_counts.append(mem_ops)

    import matplotlib.pyplot as plt
    plt.plot(ns, mem_counts)
    plt.xlabel("Number of live values")
    plt.ylabel("Memory operations used")
    plt.title("Memory operations used against live values")
    # Enable minor ticks to allow for a finer grid
    plt.minorticks_on()

    plt.gca().set_ylim(bottom=0)
    plt.gca().set_xlim(left=0)
    plt.gca().spines['top'].set_visible(False)
    plt.gca().spines['right'].set_visible(False)
    # Customize the major grid (the primary lines)
    plt.grid(visible=True, which='major', color='#666666', linestyle='-', alpha=0.6)

    plt.savefig("build/test-spilling.svg")

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