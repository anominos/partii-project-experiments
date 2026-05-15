from xdsl.dialects import func, builtin
from xdsl.ir import Block, Region
from xdsl.dialects.builtin import f32

from xdsl.transforms import reconcile_unrealized_casts, riscv_legalize_parallel_mov, riscv_allocate_infinite_registers, riscv_allocate_registers, riscv_lower_parallel_mov, riscv_reorder_infinite

from xdsl.backend.riscv.lowering import convert_func_to_riscv_func

# 2. Define the argument types (e.g., two 32-bit integers)
input_types = [f32, f32]
output_types = [f32, f32]

# 3. Create the function body
# The block arguments represent the function parameters (a and b)
block = Block(arg_types=input_types)
a, b = block.args

# 4. Create the return operation, swapping the order (b, a)
ret_op = func.ReturnOp(b, a)
block.add_op(ret_op)

# 5. Wrap the block in a region and create the func.func operation
region = Region(block)
func_op = func.FuncOp(
    "swap",
    (input_types, output_types),
    region
)

module = builtin.ModuleOp([func_op])


convert_func_to_riscv_func.ConvertFuncToRiscvFuncPass().apply(None, module)
reconcile_unrealized_casts.ReconcileUnrealizedCastsPass().apply(None, module)
riscv_legalize_parallel_mov.RISCVLegalizeParallelMovPass().apply(None, module)
riscv_allocate_registers.RISCVAllocateRegistersPass(force_infinite=True).apply(None, module)
print(module)
print()

riscv_reorder_infinite.RISCVReorderInfinitePass().apply(None, module)
print(module)
