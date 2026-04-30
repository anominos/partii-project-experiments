
from xdsl.dialects.riscv import *
from xdsl.dialects.riscv.stack import *
from xdsl.dialects.riscv_func import FuncOp, ReturnOp
from xdsl.dialects.builtin import ModuleOp, IntAttr, i32

from xdsl.backend.riscv.lowering import convert_riscv_stack_to_riscv

l = [
    a:=LuiOp(101, rd=Registers.A5),
    a_ptr:=AllocaOp(i32),
    StoreOp(a_ptr, a),
    b:=LoadOp(a_ptr),
    b_ptr:=AllocaOp(i32),
    StoreOp(b_ptr, b),
    ReturnOp(),
]

moduleop = ModuleOp([FuncOp("main", l, ([], []))])
moduleop.verify()
# print(moduleop)

convert_riscv_stack_to_riscv.ConvertRiscvStackToRiscvPass().apply(None, moduleop)

print(moduleop)