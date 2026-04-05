builtin.module {
  riscv_func.func @main() {
    %m0 = memref.alloca() : memref<i32>
    %m1 = memref.alloca() : memref<i32>
    %m2 = memref.alloca() : memref<i32>
    %v = "test.op"() : () -> i32
    %v_1 = builtin.unrealized_conversion_cast %v : i32 to !riscv.reg
    %0 = rv32.get_register : !riscv.reg<sp>
    riscv.sw %0, %v_1, 0 {comment = "store int value to memref of shape ()"} : (!riscv.reg<sp>, !riscv.reg) -> ()
    %v_2 = builtin.unrealized_conversion_cast %v : i32 to !riscv.reg
    %1 = rv32.get_register : !riscv.reg<sp>
    riscv.sw %1, %v_2, 4 {comment = "store int value to memref of shape ()"} : (!riscv.reg<sp>, !riscv.reg) -> ()
    %v_3 = builtin.unrealized_conversion_cast %v : i32 to !riscv.reg
    %2 = rv32.get_register : !riscv.reg<sp>
    riscv.sw %2, %v_3, 8 {comment = "store int value to memref of shape ()"} : (!riscv.reg<sp>, !riscv.reg) -> ()
    riscv_func.return
  }
  riscv_func.func @second() {
    %m0 = memref.alloca() : memref<i32>
    %v = "test.op"() : () -> i32
    %v_1 = builtin.unrealized_conversion_cast %v : i32 to !riscv.reg
    %0 = rv32.get_register : !riscv.reg<sp>
    riscv.sw %0, %v_1, 0 {comment = "store int value to memref of shape ()"} : (!riscv.reg<sp>, !riscv.reg) -> ()
    riscv_func.return
  }
}

