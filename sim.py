from xdsl.dialects.riscv_func import FuncOp

def simulate(func_op: FuncOp):
    for op in func_op.walk():
        if