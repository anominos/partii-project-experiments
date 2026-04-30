riscv_func.func @second() -> () {
    %m0 = memref.alloca() : memref<i32>
    %v = memref.load %m0[] : memref<i32>
    riscv_func.return
}