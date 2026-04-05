builtin.module {
  riscv_func.func @main() {
    %0, %1, %2 = "test.op"() : () -> (!riscv.reg, !riscv.reg, !riscv.reg)
    %3 = riscv.add %0, %1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
    %4 = riscv.add %2, %3 : (!riscv.reg, !riscv.reg) -> !riscv.reg
    %5 = riscv.add %0, %1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
    riscv_func.return
  }
}