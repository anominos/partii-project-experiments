PRINT PASS 1
builtin.module {
  riscv_func.func public @pooling_nchw_max_d1_s2_3x3(%X : !riscv.reg<a0>, %Y : !riscv.reg<a1>) attributes {p2align = 2 : i8} {
    %X_subview = riscv.mv %X : (!riscv.reg<a0>) -> !riscv.reg
    %Y_subview = riscv.mv %Y : (!riscv.reg<a1>) -> !riscv.reg
    %min_val = riscv.li -10000 : !riscv.reg
    %min_val_1 = riscv.fcvt.d.w %min_val : (!riscv.reg) -> !riscv.freg
    %c0 = riscv.get_register : !riscv.reg<zero>
    %c0_1 = riscv.mv %c0 : (!riscv.reg<zero>) -> !riscv.reg
    %c1 = riscv.li 1 : !riscv.reg
    %ub = riscv.li 8 : !riscv.reg
    riscv.parallel_mov : () -> ()
    riscv_scf.for %i : !riscv.reg  = %c0_1 to %ub step %c1 {
      %X_offset = riscv.li 2 : !riscv.reg
      %X_offset_1 = riscv.mul %i, %X_offset : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %X_offset_2 = riscv.mv %X_offset_1 : (!riscv.reg) -> !riscv.reg
      %pointer_dim_stride = riscv.li 18 : !riscv.reg
      %pointer_dim_offset = riscv.mul %X_offset_2, %pointer_dim_stride : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset = riscv.mv %pointer_dim_offset : (!riscv.reg) -> !riscv.reg
      %pointer_offset_1 = riscv.mv %pointer_offset : (!riscv.reg) -> !riscv.reg
      %bytes_per_element = riscv.li 8 : !riscv.reg
      %scaled_pointer_offset = riscv.mul %pointer_offset_1, %bytes_per_element {comment = "multiply by element size"} : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %offset_pointer = riscv.add %X_subview, %scaled_pointer_offset : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_1 = riscv.li 8 : !riscv.reg
      %pointer_dim_offset_1 = riscv.mul %i, %pointer_dim_stride_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_2 = riscv.mv %pointer_dim_offset_1 : (!riscv.reg) -> !riscv.reg
      %pointer_offset_3 = riscv.mv %pointer_offset_2 : (!riscv.reg) -> !riscv.reg
      %bytes_per_element_1 = riscv.li 8 : !riscv.reg
      %scaled_pointer_offset_1 = riscv.mul %pointer_offset_3, %bytes_per_element_1 {comment = "multiply by element size"} : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %offset_pointer_1 = riscv.add %Y_subview, %scaled_pointer_offset_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      snitch_stream.streaming_region {
        patterns = [
          #snitch_stream.stride_pattern<ub = [2, 3, 3, 4], strides = [64, 144, 8, 16]>,
          #snitch_stream.stride_pattern<ub = [8], strides = [8]>
        ]
      } ins(%offset_pointer : !riscv.reg) outs(%offset_pointer_1 : !riscv.reg) {
      ^bb0(%x : !snitch.readable<!riscv.freg>, %0 : !snitch.writable<!riscv.freg>):
        %1 = riscv.li 2 : !riscv.reg
        %2 = riscv.get_register : !riscv.reg<zero>
        %3 = riscv.mv %2 : (!riscv.reg<zero>) -> !riscv.reg
        %4 = riscv.li 1 : !riscv.reg
        %5 = riscv.li 9 : !riscv.reg
        riscv.parallel_mov : () -> ()
        riscv_scf.for %6 : !riscv.reg  = %3 to %1 step %4 {
          %7, %8, %9, %10 = riscv.parallel_mov %min_val_1, %min_val_1, %min_val_1, %min_val_1 : (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) -> (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg)
          %11 = riscv.sub %5, %3 : (!riscv.reg, !riscv.reg) -> !riscv.reg
          %12 = riscv.addi %11, -1 : (!riscv.reg) -> !riscv.reg
          %13, %14, %15, %16 = riscv_snitch.frep_outer %12 iter_args(%acc = %7, %acc_1 = %8, %acc_2 = %9, %acc_3 = %10) -> (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) {
            %x_1 = riscv_snitch.read from %x : !riscv.freg
            %x_2 = riscv_snitch.read from %x : !riscv.freg
            %x_3 = riscv_snitch.read from %x : !riscv.freg
            %x_4 = riscv_snitch.read from %x : !riscv.freg
            %res = riscv.fmax.d %x_1, %acc : (!riscv.freg, !riscv.freg) -> !riscv.freg
            %res_1 = riscv.fmax.d %x_2, %acc_1 : (!riscv.freg, !riscv.freg) -> !riscv.freg
            %res_2 = riscv.fmax.d %x_3, %acc_2 : (!riscv.freg, !riscv.freg) -> !riscv.freg
            %res_3 = riscv.fmax.d %x_4, %acc_3 : (!riscv.freg, !riscv.freg) -> !riscv.freg
            riscv_snitch.frep_yield %res, %res_1, %res_2, %res_3 : !riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg
          }
          %17, %18, %19, %20 = riscv.parallel_mov %13, %14, %15, %16 : (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) -> (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg)
          riscv_snitch.write %17 to %0 : !riscv.freg
          riscv_snitch.write %18 to %0 : !riscv.freg
          riscv_snitch.write %19 to %0 : !riscv.freg
          riscv_snitch.write %20 to %0 : !riscv.freg
        }
        riscv.parallel_mov : () -> ()
      }
    }
    riscv.parallel_mov : () -> ()
    riscv_func.return
  }
}
-------------------------
PRINT PASS 2
builtin.module {
  riscv_func.func public @pooling_nchw_max_d1_s2_3x3(%X : !riscv.reg<a0>, %Y : !riscv.reg<a1>) attributes {p2align = 2 : i8} {
    %X_subview = riscv.mv %X : (!riscv.reg<a0>) -> !riscv.reg
    %Y_subview = riscv.mv %Y : (!riscv.reg<a1>) -> !riscv.reg
    %min_val = riscv.li -10000 : !riscv.reg
    %min_val_1 = riscv.fcvt.d.w %min_val : (!riscv.reg) -> !riscv.freg
    %c0 = riscv.get_register : !riscv.reg<zero>
    %c0_1 = riscv.mv %c0 : (!riscv.reg<zero>) -> !riscv.reg
    %c1 = riscv.li 1 : !riscv.reg
    %ub = riscv.li 8 : !riscv.reg
    riscv.parallel_mov : () -> ()
    riscv_scf.for %i : !riscv.reg  = %c0_1 to %ub step %c1 {
      %X_offset = riscv.li 2 : !riscv.reg
      %X_offset_1 = riscv.mul %i, %X_offset : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %X_offset_2 = riscv.mv %X_offset_1 : (!riscv.reg) -> !riscv.reg
      %pointer_dim_stride = riscv.li 18 : !riscv.reg
      %pointer_dim_offset = riscv.mul %X_offset_2, %pointer_dim_stride : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset = riscv.mv %pointer_dim_offset : (!riscv.reg) -> !riscv.reg
      %pointer_offset_1 = riscv.mv %pointer_offset : (!riscv.reg) -> !riscv.reg
      %bytes_per_element = riscv.li 8 : !riscv.reg
      %scaled_pointer_offset = riscv.mul %pointer_offset_1, %bytes_per_element {comment = "multiply by element size"} : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %offset_pointer = riscv.add %X_subview, %scaled_pointer_offset : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_1 = riscv.li 8 : !riscv.reg
      %pointer_dim_offset_1 = riscv.mul %i, %pointer_dim_stride_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_2 = riscv.mv %pointer_dim_offset_1 : (!riscv.reg) -> !riscv.reg
      %pointer_offset_3 = riscv.mv %pointer_offset_2 : (!riscv.reg) -> !riscv.reg
      %bytes_per_element_1 = riscv.li 8 : !riscv.reg
      %scaled_pointer_offset_1 = riscv.mul %pointer_offset_3, %bytes_per_element_1 {comment = "multiply by element size"} : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %offset_pointer_1 = riscv.add %Y_subview, %scaled_pointer_offset_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      snitch_stream.streaming_region {
        patterns = [
          #snitch_stream.stride_pattern<ub = [2, 3, 3, 4], strides = [64, 144, 8, 16]>,
          #snitch_stream.stride_pattern<ub = [8], strides = [8]>
        ]
      } ins(%offset_pointer : !riscv.reg) outs(%offset_pointer_1 : !riscv.reg) {
      ^bb0(%x : !snitch.readable<!riscv.freg<ft0>>, %0 : !snitch.writable<!riscv.freg<ft1>>):
        %1 = riscv.li 2 : !riscv.reg
        %2 = riscv.get_register : !riscv.reg<zero>
        %3 = riscv.mv %2 : (!riscv.reg<zero>) -> !riscv.reg
        %4 = riscv.li 1 : !riscv.reg
        %5 = riscv.li 9 : !riscv.reg
        riscv.parallel_mov : () -> ()
        riscv_scf.for %6 : !riscv.reg  = %3 to %1 step %4 {
          %7, %8, %9, %10 = riscv.parallel_mov %min_val_1, %min_val_1, %min_val_1, %min_val_1 : (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) -> (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg)
          %11 = riscv.sub %5, %3 : (!riscv.reg, !riscv.reg) -> !riscv.reg
          %12 = riscv.addi %11, -1 : (!riscv.reg) -> !riscv.reg
          %13, %14, %15, %16 = riscv_snitch.frep_outer %12 iter_args(%acc = %7, %acc_1 = %8, %acc_2 = %9, %acc_3 = %10) -> (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) {
            %x_1 = riscv_snitch.read from %x : !riscv.freg<ft0>
            %x_2 = riscv_snitch.read from %x : !riscv.freg<ft0>
            %x_3 = riscv_snitch.read from %x : !riscv.freg<ft0>
            %x_4 = riscv_snitch.read from %x : !riscv.freg<ft0>
            %res = riscv.fmax.d %x_1, %acc : (!riscv.freg<ft0>, !riscv.freg) -> !riscv.freg
            %res_1 = riscv.fmax.d %x_2, %acc_1 : (!riscv.freg<ft0>, !riscv.freg) -> !riscv.freg
            %res_2 = riscv.fmax.d %x_3, %acc_2 : (!riscv.freg<ft0>, !riscv.freg) -> !riscv.freg
            %res_3 = riscv.fmax.d %x_4, %acc_3 : (!riscv.freg<ft0>, !riscv.freg) -> !riscv.freg
            riscv_snitch.frep_yield %res, %res_1, %res_2, %res_3 : !riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg
          }
          %17, %18, %19, %20 = riscv.parallel_mov %13, %14, %15, %16 : (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) -> (!riscv.freg<ft1>, !riscv.freg<ft1>, !riscv.freg<ft1>, !riscv.freg<ft1>)
          riscv_snitch.write %17 to %0 : !riscv.freg<ft1>
          riscv_snitch.write %18 to %0 : !riscv.freg<ft1>
          riscv_snitch.write %19 to %0 : !riscv.freg<ft1>
          riscv_snitch.write %20 to %0 : !riscv.freg<ft1>
        }
        riscv.parallel_mov : () -> ()
      }
    }
    riscv.parallel_mov : () -> ()
    riscv_func.return
  }
}
-------------------------
builtin.module {
  riscv_func.func public @pooling_nchw_max_d1_s2_3x3(%X : !riscv.reg<a0>, %Y : !riscv.reg<a1>) attributes {p2align = 2 : i8} {
    %X_subview = riscv.mv %X : (!riscv.reg<a0>) -> !riscv.reg
    %Y_subview = riscv.mv %Y : (!riscv.reg<a1>) -> !riscv.reg
    %min_val = riscv.li -10000 : !riscv.reg
    %min_val_1 = riscv.fcvt.d.w %min_val : (!riscv.reg) -> !riscv.freg
    %c0 = riscv.get_register : !riscv.reg<zero>
    %c0_1 = riscv.mv %c0 : (!riscv.reg<zero>) -> !riscv.reg
    %c1 = riscv.li 1 : !riscv.reg
    %ub = riscv.li 8 : !riscv.reg
    riscv.parallel_mov : () -> ()
    riscv_scf.for %i : !riscv.reg  = %c0_1 to %ub step %c1 {
      %X_offset = riscv.li 2 : !riscv.reg
      %X_offset_1 = riscv.mul %i, %X_offset : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %X_offset_2 = riscv.mv %X_offset_1 : (!riscv.reg) -> !riscv.reg
      %pointer_dim_stride = riscv.li 18 : !riscv.reg
      %pointer_dim_offset = riscv.mul %X_offset_2, %pointer_dim_stride : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset = riscv.mv %pointer_dim_offset : (!riscv.reg) -> !riscv.reg
      %pointer_offset_1 = riscv.mv %pointer_offset : (!riscv.reg) -> !riscv.reg
      %bytes_per_element = riscv.li 8 : !riscv.reg
      %scaled_pointer_offset = riscv.mul %pointer_offset_1, %bytes_per_element {comment = "multiply by element size"} : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %offset_pointer = riscv.add %X_subview, %scaled_pointer_offset : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_1 = riscv.li 8 : !riscv.reg
      %pointer_dim_offset_1 = riscv.mul %i, %pointer_dim_stride_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_2 = riscv.mv %pointer_dim_offset_1 : (!riscv.reg) -> !riscv.reg
      %pointer_offset_3 = riscv.mv %pointer_offset_2 : (!riscv.reg) -> !riscv.reg
      %bytes_per_element_1 = riscv.li 8 : !riscv.reg
      %scaled_pointer_offset_1 = riscv.mul %pointer_offset_3, %bytes_per_element_1 {comment = "multiply by element size"} : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %offset_pointer_1 = riscv.add %Y_subview, %scaled_pointer_offset_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %0 = riscv.li 3 : !riscv.reg
      riscv_snitch.scfgwi %0, 64 {comment = "dm 0 dim 0 bound"} : (!riscv.reg) -> ()
      %1 = riscv.li 2 : !riscv.reg
      riscv_snitch.scfgwi %1, 96 {comment = "dm 0 dim 1 bound"} : (!riscv.reg) -> ()
      %2 = riscv.li 2 : !riscv.reg
      riscv_snitch.scfgwi %2, 128 {comment = "dm 0 dim 2 bound"} : (!riscv.reg) -> ()
      %3 = riscv.li 1 : !riscv.reg
      riscv_snitch.scfgwi %3, 160 {comment = "dm 0 dim 3 bound"} : (!riscv.reg) -> ()
      %4 = riscv.li 16 : !riscv.reg
      riscv_snitch.scfgwi %4, 192 {comment = "dm 0 dim 0 stride"} : (!riscv.reg) -> ()
      %5 = riscv.li -40 : !riscv.reg
      riscv_snitch.scfgwi %5, 224 {comment = "dm 0 dim 1 stride"} : (!riscv.reg) -> ()
      %6 = riscv.li 80 : !riscv.reg
      riscv_snitch.scfgwi %6, 256 {comment = "dm 0 dim 2 stride"} : (!riscv.reg) -> ()
      %7 = riscv.li -288 : !riscv.reg
      riscv_snitch.scfgwi %7, 288 {comment = "dm 0 dim 3 stride"} : (!riscv.reg) -> ()
      %8 = riscv.get_register : !riscv.reg<zero>
      %9 = riscv.mv %8 : (!riscv.reg<zero>) -> !riscv.reg
      riscv_snitch.scfgwi %9, 32 {comment = "dm 0 repeat"} : (!riscv.reg) -> ()
      %10 = riscv.li 7 : !riscv.reg
      riscv_snitch.scfgwi %10, 65 {comment = "dm 1 dim 0 bound"} : (!riscv.reg) -> ()
      %11 = riscv.li 8 : !riscv.reg
      riscv_snitch.scfgwi %11, 193 {comment = "dm 1 dim 0 stride"} : (!riscv.reg) -> ()
      %12 = riscv.get_register : !riscv.reg<zero>
      %13 = riscv.mv %12 : (!riscv.reg<zero>) -> !riscv.reg
      riscv_snitch.scfgwi %13, 33 {comment = "dm 1 repeat"} : (!riscv.reg) -> ()
      riscv_snitch.scfgwi %offset_pointer, 864 {comment = "dm 0 dim 3 source"} : (!riscv.reg) -> ()
      riscv_snitch.scfgwi %offset_pointer_1, 897 {comment = "dm 1 dim 0 destination"} : (!riscv.reg) -> ()
      %14 = riscv.csrrsi 1984, 1 {comment = "SSR enable"} : () -> !riscv.reg<zero>
      %x = riscv_snitch.get_stream : !snitch.readable<!riscv.freg<ft0>>
      %15 = riscv_snitch.get_stream : !snitch.writable<!riscv.freg<ft1>>
      %16 = riscv.li 2 : !riscv.reg
      %17 = riscv.get_register : !riscv.reg<zero>
      %18 = riscv.mv %17 : (!riscv.reg<zero>) -> !riscv.reg
      %19 = riscv.li 1 : !riscv.reg
      riscv.parallel_mov : () -> ()
      riscv_scf.for %20 : !riscv.reg  = %18 to %16 step %19 {
        %21, %22, %23, %24 = riscv.parallel_mov %min_val_1, %min_val_1, %min_val_1, %min_val_1 : (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) -> (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg)
        %25 = riscv.li 8 : !riscv.reg
        %26, %27, %28, %29 = riscv_snitch.frep_outer %25 iter_args(%acc = %21, %acc_1 = %22, %acc_2 = %23, %acc_3 = %24) -> (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) {
          %x_1 = riscv_snitch.read from %x : !riscv.freg<ft0>
          %x_2 = riscv_snitch.read from %x : !riscv.freg<ft0>
          %x_3 = riscv_snitch.read from %x : !riscv.freg<ft0>
          %x_4 = riscv_snitch.read from %x : !riscv.freg<ft0>
          %res = riscv.fmax.d %x_1, %acc : (!riscv.freg<ft0>, !riscv.freg) -> !riscv.freg
          %res_1 = riscv.fmax.d %x_2, %acc_1 : (!riscv.freg<ft0>, !riscv.freg) -> !riscv.freg
          %res_2 = riscv.fmax.d %x_3, %acc_2 : (!riscv.freg<ft0>, !riscv.freg) -> !riscv.freg
          %res_3 = riscv.fmax.d %x_4, %acc_3 : (!riscv.freg<ft0>, !riscv.freg) -> !riscv.freg
          riscv_snitch.frep_yield %res, %res_1, %res_2, %res_3 : !riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg
        }
        %30, %31, %32, %33 = riscv.parallel_mov %26, %27, %28, %29 : (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) -> (!riscv.freg<ft1>, !riscv.freg<ft1>, !riscv.freg<ft1>, !riscv.freg<ft1>)
        riscv_snitch.write %30 to %15 : !riscv.freg<ft1>
        riscv_snitch.write %31 to %15 : !riscv.freg<ft1>
        riscv_snitch.write %32 to %15 : !riscv.freg<ft1>
        riscv_snitch.write %33 to %15 : !riscv.freg<ft1>
      }
      riscv.parallel_mov : () -> ()
      %34 = riscv.csrrci 1984, 1 {comment = "SSR disable"} : () -> !riscv.reg<zero>
    }
    riscv.parallel_mov : () -> ()
    riscv_func.return
  }
}
ALLOCATING
riscv.parallel_mov : () -> ()
ALLOCATING
riscv.parallel_mov : () -> ()
ALLOCATING
%0, %1, %2, %3 = riscv.parallel_mov %4, %5, %6, %7 : (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) -> (!riscv.freg<ft1>, !riscv.freg<ft1>, !riscv.freg<ft1>, !riscv.freg<ft1>)
ALLOCATING
%0, %1, %2, %3 = riscv.parallel_mov %min_val, %min_val, %min_val, %min_val : (!riscv.freg<ft3>, !riscv.freg<ft3>, !riscv.freg<ft3>, !riscv.freg<ft3>) -> (!riscv.freg<ft4>, !riscv.freg<ft5>, !riscv.freg<ft6>, !riscv.freg<ft7>)
ALLOCATING
riscv.parallel_mov : () -> ()
ALLOCATING
riscv.parallel_mov : () -> ()
pmov lowering
riscv.parallel_mov : () -> ()
pmov lowering
riscv.parallel_mov : () -> ()
pmov lowering
%0, %1, %2, %3 = riscv.parallel_mov %min_val, %min_val, %min_val, %min_val : (!riscv.freg<ft3>, !riscv.freg<ft3>, !riscv.freg<ft3>, !riscv.freg<ft3>) -> (!riscv.freg<ft4>, !riscv.freg<ft5>, !riscv.freg<ft6>, !riscv.freg<ft7>)
pmov lowering
%0, %1, %2, %3 = riscv.parallel_mov %4, %5, %6, %7 : (!riscv.freg<ft4>, !riscv.freg<ft5>, !riscv.freg<ft6>, !riscv.freg<ft7>) -> (!riscv.freg<ft1>, !riscv.freg<ft1>, !riscv.freg<ft1>, !riscv.freg<ft1>)
