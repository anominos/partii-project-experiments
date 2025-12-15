builtin.module {
  %0, %1, %2 = "test.op"() : () -> (!riscv.reg<s1>, !riscv.reg<s2>, !riscv.reg<s3>)
  %3, %4, %5 = riscv.parallel_mov %0, %1, %2  : (!riscv.reg<s1>, !riscv.reg<s2>, !riscv.reg<s3>) -> (!riscv.reg<s2>, !riscv.reg<s1>, !riscv.reg<s4>)
  "test.op"(%3, %4, %5) : (!riscv.reg<s2>, !riscv.reg<s1>, !riscv.reg<s4>) -> ()
}