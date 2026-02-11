builtin.module {
  riscv_func.func @external() -> () 
  riscv_func.func @main() {
    %zero = riscv.li 0 : !riscv.reg<zero>
    %0 = riscv.li 6 : !riscv.reg<j_1>
    %1 = riscv.li 5 : !riscv.reg<s0>
    %2 = riscv.fcvt.s.w %0 : (!riscv.reg<j_1>) -> !riscv.freg<fj_0>
    %3 = riscv.fcvt.s.w %1 : (!riscv.reg<s0>) -> !riscv.freg<fj_1>
    %4 = riscv.fadd.s %2, %3 : (!riscv.freg<fj_0>, !riscv.freg<fj_1>) -> !riscv.freg<fj_0>
    %5 = riscv.add %0, %1 : (!riscv.reg<j_1>, !riscv.reg<s0>) -> !riscv.reg<j_0>
    riscv_scf.for %6 : !riscv.reg<j_0>  = %0 to %1 step %5 {
    }
    %7 = riscv_scf.for %8 : !riscv.reg<j_1>  = %0 to %1 step %5 iter_args(%9 = %5) -> (!riscv.reg<j_0>) {
      %10 = riscv.mv %9 : (!riscv.reg<j_0>) -> !riscv.reg<j_0>
      riscv_scf.yield %10 : !riscv.reg<j_0>
    }
    %zero_1 = riscv.li 0 : !riscv.reg<zero>
    %zero_2 = riscv.li 0 : !riscv.reg<a0>
    riscv_func.return
  }
}

