builtin.module {
  riscv_func.func @first() {
    %0 = rv32.get_register : !riscv.reg<sp>
    %1 = riscv.addi %0, -16 : (!riscv.reg<sp>) -> !riscv.reg<sp>
    %v = "test.op"() : () -> !riscv.reg<t0>
    %v_i32 = builtin.unrealized_conversion_cast %v : !riscv.reg<t0> to i32
    %v_i32_1 = builtin.unrealized_conversion_cast %v_i32 : i32 to !riscv.reg
    %2 = rv32.get_register : !riscv.reg<sp>
    riscv.sw %2, %v_i32_1, 0 {comment = "store int value to memref of shape ()"} : (!riscv.reg<sp>, !riscv.reg) -> ()





    %3 = rv32.get_register : !riscv.reg<sp>
    %v1_i32 = riscv.lw %3, 0 {comment = "load word from memref of shape ()"} : (!riscv.reg<sp>) -> !riscv.reg
    %v1_i32_1 = builtin.unrealized_conversion_cast %v1_i32 : !riscv.reg to i32
    %v1 = builtin.unrealized_conversion_cast %v1_i32_1 : i32 to !riscv.reg<t0>
    %4 = riscv.addi %0, 16 : (!riscv.reg<sp>) -> !riscv.reg<sp>
    riscv_func.return
  }
}

