// riscv_func.func @main() {
//   %0 = riscv.li 6 : !riscv.reg
//   %1 = riscv.li 5 : !riscv.reg<s0>
//   %5 = riscv.add %0, %1 : (!riscv.reg, !riscv.reg<s0>) -> !riscv.reg
//   %7 = riscv_scf.for %8 : !riscv.reg = %0 to  %1 step %5 iter_args(%9 = %5) -> (!riscv.reg) {
//     %10 = riscv.mv %9 : (!riscv.reg) -> !riscv.reg
//     riscv_scf.yield %10 : !riscv.reg
//   }
//   riscv_func.return
// }

builtin.module {
  riscv_func.func @main() {
    %0 = riscv.li 6 : !riscv.reg<j_1>
    %1 = riscv.li 5 : !riscv.reg<s0>
    %2 = riscv.add %0, %1 : (!riscv.reg<j_1>, !riscv.reg<s0>) -> !riscv.reg<j_0>
    %3 = riscv_scf.for %4 : !riscv.reg<j_1>  = %0 to %1 step %2 iter_args(%5 = %2) -> (!riscv.reg<j_0>) {
      // riscv.mv %4 : (!riscv.reg<j_1>) -> !riscv.reg<zero>
      %6 = riscv.mv %5 : (!riscv.reg<j_0>) -> !riscv.reg<j_0>
      riscv_scf.yield %6 : !riscv.reg<j_0>
    }
    riscv_func.return
  }
}