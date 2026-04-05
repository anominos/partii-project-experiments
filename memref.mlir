builtin.module {
    riscv_func.func @main() -> () {
        %m0 = memref.alloca() : memref<i32>
        %m1 = memref.alloca() : memref<i32>
        %m2 = memref.alloca() : memref<i32>
        %v = "test.op"() : () -> (i32)
        memref.store %v, %m0[] : memref<i32>
        memref.store %v, %m1[] : memref<i32>
        memref.store %v, %m2[] : memref<i32>
        riscv_func.return
    }
    riscv_func.func @second() -> () {
        %m0 = memref.alloca() : memref<i32>
        %v = "test.op"() : () -> (i32)
        memref.store %v, %m0[] : memref<i32>
        riscv_func.return
    }
}

