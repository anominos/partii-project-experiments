builtin.module {
  riscv_func.func @main() -> (!riscv.freg, !riscv.freg) {
    %0, %1, %2 = "test.op"() : () -> (!riscv.freg<fj_0>, !riscv.freg<fj_1>, !riscv.freg<fj_2>)
    %3, %4, %5 = riscv.parallel_mov %0, %1, %2 [32, 32, 32] : (!riscv.freg<fj_0>, !riscv.freg<fj_1>, !riscv.freg<fj_2>) -> (!riscv.freg<ft0>, !riscv.freg<fj_0>, !riscv.freg<fj_1>)
    riscv_func.return %3, %4, %5 : !riscv.freg<ft0>, !riscv.freg<fj_0>, !riscv.freg<fj_1>
  }
}