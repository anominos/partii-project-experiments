before op
builtin.module {
  func.func public @pooling_nchw_max_d1_s2_3x3(%X : memref<1x1x18x18xf64>, %Y : memref<1x1x8x8xf64>) {
    %min_val = arith.constant -1.000000e+04 : f64
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %ub = arith.constant 8 : index
    scf.for %i = %c0 to %ub step %c1 {
      %X_offset = arith.constant 2 : index
      %X_offset_1 = arith.muli %i, %X_offset : index
      %X_offset_2 = arith.addi %X_offset_1, %c0 : index
      %X_offset_3 = arith.constant 8 : index
      %X_offset_4 = arith.muli %c0, %X_offset_3 : index
      %X_offset_5 = arith.constant 2 : index
      %X_offset_6 = arith.muli %c0, %X_offset_5 : index
      %X_offset_7 = arith.addi %X_offset_4, %X_offset_6 : index
      %X_offset_8 = arith.addi %X_offset_7, %c0 : index
      %X_subview = builtin.unrealized_conversion_cast %X : memref<1x1x18x18xf64> to !riscv.reg
      %subview_dim_index = builtin.unrealized_conversion_cast %c0 : index to !riscv.reg
      %subview_dim_index_1 = builtin.unrealized_conversion_cast %c0 : index to !riscv.reg
      %subview_dim_index_2 = builtin.unrealized_conversion_cast %X_offset_2 : index to !riscv.reg
      %subview_dim_index_3 = builtin.unrealized_conversion_cast %X_offset_8 : index to !riscv.reg
      %pointer_dim_stride = riscv.li 324 : !riscv.reg
      %pointer_dim_offset = riscv.mul %subview_dim_index, %pointer_dim_stride : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_1 = riscv.li 324 : !riscv.reg
      %pointer_dim_offset_1 = riscv.mul %subview_dim_index_1, %pointer_dim_stride_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset = riscv.add %pointer_dim_offset, %pointer_dim_offset_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_2 = riscv.li 18 : !riscv.reg
      %pointer_dim_offset_2 = riscv.mul %subview_dim_index_2, %pointer_dim_stride_2 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_1 = riscv.add %pointer_offset, %pointer_dim_offset_2 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_2 = riscv.add %pointer_offset_1, %subview_dim_index_3 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %bytes_per_element = riscv.li 8 : !riscv.reg
      %scaled_pointer_offset = riscv.mul %pointer_offset_2, %bytes_per_element {comment = "multiply by element size"} : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %offset_pointer = riscv.add %X_subview, %scaled_pointer_offset : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %X_subview_1 = builtin.unrealized_conversion_cast %offset_pointer : !riscv.reg to memref<1x1x3x17xf64, strided<[324, 324, 18, 1], offset: ?>>
      %Y_offset = arith.constant 4 : index
      %Y_offset_1 = arith.muli %c0, %Y_offset : index
      %Y_offset_2 = arith.addi %Y_offset_1, %c0 : index
      %Y_subview = builtin.unrealized_conversion_cast %Y : memref<1x1x8x8xf64> to !riscv.reg
      %subview_dim_index_4 = builtin.unrealized_conversion_cast %c0 : index to !riscv.reg
      %subview_dim_index_5 = builtin.unrealized_conversion_cast %c0 : index to !riscv.reg
      %subview_dim_index_6 = builtin.unrealized_conversion_cast %i : index to !riscv.reg
      %subview_dim_index_7 = builtin.unrealized_conversion_cast %Y_offset_2 : index to !riscv.reg
      %pointer_dim_stride_3 = riscv.li 64 : !riscv.reg
      %pointer_dim_offset_3 = riscv.mul %subview_dim_index_4, %pointer_dim_stride_3 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_4 = riscv.li 64 : !riscv.reg
      %pointer_dim_offset_4 = riscv.mul %subview_dim_index_5, %pointer_dim_stride_4 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_3 = riscv.add %pointer_dim_offset_3, %pointer_dim_offset_4 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_5 = riscv.li 8 : !riscv.reg
      %pointer_dim_offset_5 = riscv.mul %subview_dim_index_6, %pointer_dim_stride_5 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_4 = riscv.add %pointer_offset_3, %pointer_dim_offset_5 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_5 = riscv.add %pointer_offset_4, %subview_dim_index_7 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %bytes_per_element_1 = riscv.li 8 : !riscv.reg
      %scaled_pointer_offset_1 = riscv.mul %pointer_offset_5, %bytes_per_element_1 {comment = "multiply by element size"} : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %offset_pointer_1 = riscv.add %Y_subview, %scaled_pointer_offset_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %Y_subview_1 = builtin.unrealized_conversion_cast %offset_pointer_1 : !riscv.reg to memref<1x1x1x8xf64, strided<[64, 64, 8, 1], offset: ?>>
      memref_stream.streaming_region {
        patterns = [
          #memref_stream.stride_pattern<ub = [1, 1, 1, 2, 3, 3, 4], index_map = (d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, ((d2 * 2) + d4), (((d3 * 8) + (d6 * 2)) + d5))>,
          #memref_stream.stride_pattern<ub = [1, 1, 1, 2, 4], index_map = (d0, d1, d2, d3, d4) -> (d0, d1, d2, ((d3 * 4) + d4))>
        ]
      } ins(%X_subview_1 : memref<1x1x3x17xf64, strided<[324, 324, 18, 1], offset: ?>>) outs(%Y_subview_1 : memref<1x1x1x8xf64, strided<[64, 64, 8, 1], offset: ?>>) {
      ^bb0(%0 : !memref_stream.readable<f64>, %1 : !memref_stream.writable<f64>):
        %2 = arith.constant 2 : index
        %3 = arith.constant 0 : index
        %4 = arith.constant 1 : index
        %5 = arith.constant 9 : index
        scf.for %6 = %3 to %2 step %4 {
          %7, %8, %9, %10 = scf.for %11 = %3 to %5 step %4 iter_args(%acc = %min_val, %acc_1 = %min_val, %acc_2 = %min_val, %acc_3 = %min_val) -> (f64, f64, f64, f64) {
            %x = memref_stream.read from %0 : f64
            %x_1 = memref_stream.read from %0 : f64
            %x_2 = memref_stream.read from %0 : f64
            %x_3 = memref_stream.read from %0 : f64
            %res = arith.maximumf %x, %acc : f64
            %res_1 = arith.maximumf %x_1, %acc_1 : f64
            %res_2 = arith.maximumf %x_2, %acc_2 : f64
            %res_3 = arith.maximumf %x_3, %acc_3 : f64
            scf.yield %res, %res_1, %res_2, %res_3 : f64, f64, f64, f64
          }
          memref_stream.write %7 to %1 : f64
          memref_stream.write %8 to %1 : f64
          memref_stream.write %9 to %1 : f64
          memref_stream.write %10 to %1 : f64
        }
      }
    }
    func.return
  }
}
--------
after op
builtin.module {
  func.func public @pooling_nchw_max_d1_s2_3x3(%X : memref<1x1x18x18xf64>, %Y : memref<1x1x8x8xf64>) {
    %min_val = arith.constant -1.000000e+04 : f64
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %ub = arith.constant 8 : index
    %c0_1 = builtin.unrealized_conversion_cast %c0 : index to !riscv.reg
    %ub_1 = builtin.unrealized_conversion_cast %ub : index to !riscv.reg
    %c1_1 = builtin.unrealized_conversion_cast %c1 : index to !riscv.reg
    riscv.parallel_mov : () -> ()
    riscv_scf.for %i : !riscv.reg  = %c0_1 to %ub_1 step %c1_1 {
      %i_1 = builtin.unrealized_conversion_cast %i : !riscv.reg to index
      %X_offset = arith.constant 2 : index
      %X_offset_1 = arith.muli %i_1, %X_offset : index
      %X_offset_2 = arith.addi %X_offset_1, %c0 : index
      %X_offset_3 = arith.constant 8 : index
      %X_offset_4 = arith.muli %c0, %X_offset_3 : index
      %X_offset_5 = arith.constant 2 : index
      %X_offset_6 = arith.muli %c0, %X_offset_5 : index
      %X_offset_7 = arith.addi %X_offset_4, %X_offset_6 : index
      %X_offset_8 = arith.addi %X_offset_7, %c0 : index
      %X_subview = builtin.unrealized_conversion_cast %X : memref<1x1x18x18xf64> to !riscv.reg
      %subview_dim_index = builtin.unrealized_conversion_cast %c0 : index to !riscv.reg
      %subview_dim_index_1 = builtin.unrealized_conversion_cast %c0 : index to !riscv.reg
      %subview_dim_index_2 = builtin.unrealized_conversion_cast %X_offset_2 : index to !riscv.reg
      %subview_dim_index_3 = builtin.unrealized_conversion_cast %X_offset_8 : index to !riscv.reg
      %pointer_dim_stride = riscv.li 324 : !riscv.reg
      %pointer_dim_offset = riscv.mul %subview_dim_index, %pointer_dim_stride : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_1 = riscv.li 324 : !riscv.reg
      %pointer_dim_offset_1 = riscv.mul %subview_dim_index_1, %pointer_dim_stride_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset = riscv.add %pointer_dim_offset, %pointer_dim_offset_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_2 = riscv.li 18 : !riscv.reg
      %pointer_dim_offset_2 = riscv.mul %subview_dim_index_2, %pointer_dim_stride_2 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_1 = riscv.add %pointer_offset, %pointer_dim_offset_2 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_2 = riscv.add %pointer_offset_1, %subview_dim_index_3 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %bytes_per_element = riscv.li 8 : !riscv.reg
      %scaled_pointer_offset = riscv.mul %pointer_offset_2, %bytes_per_element {comment = "multiply by element size"} : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %offset_pointer = riscv.add %X_subview, %scaled_pointer_offset : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %X_subview_1 = builtin.unrealized_conversion_cast %offset_pointer : !riscv.reg to memref<1x1x3x17xf64, strided<[324, 324, 18, 1], offset: ?>>
      %Y_offset = arith.constant 4 : index
      %Y_offset_1 = arith.muli %c0, %Y_offset : index
      %Y_offset_2 = arith.addi %Y_offset_1, %c0 : index
      %Y_subview = builtin.unrealized_conversion_cast %Y : memref<1x1x8x8xf64> to !riscv.reg
      %subview_dim_index_4 = builtin.unrealized_conversion_cast %c0 : index to !riscv.reg
      %subview_dim_index_5 = builtin.unrealized_conversion_cast %c0 : index to !riscv.reg
      %subview_dim_index_6 = builtin.unrealized_conversion_cast %i_1 : index to !riscv.reg
      %subview_dim_index_7 = builtin.unrealized_conversion_cast %Y_offset_2 : index to !riscv.reg
      %pointer_dim_stride_3 = riscv.li 64 : !riscv.reg
      %pointer_dim_offset_3 = riscv.mul %subview_dim_index_4, %pointer_dim_stride_3 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_4 = riscv.li 64 : !riscv.reg
      %pointer_dim_offset_4 = riscv.mul %subview_dim_index_5, %pointer_dim_stride_4 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_3 = riscv.add %pointer_dim_offset_3, %pointer_dim_offset_4 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_dim_stride_5 = riscv.li 8 : !riscv.reg
      %pointer_dim_offset_5 = riscv.mul %subview_dim_index_6, %pointer_dim_stride_5 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_4 = riscv.add %pointer_offset_3, %pointer_dim_offset_5 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %pointer_offset_5 = riscv.add %pointer_offset_4, %subview_dim_index_7 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %bytes_per_element_1 = riscv.li 8 : !riscv.reg
      %scaled_pointer_offset_1 = riscv.mul %pointer_offset_5, %bytes_per_element_1 {comment = "multiply by element size"} : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %offset_pointer_1 = riscv.add %Y_subview, %scaled_pointer_offset_1 : (!riscv.reg, !riscv.reg) -> !riscv.reg
      %Y_subview_1 = builtin.unrealized_conversion_cast %offset_pointer_1 : !riscv.reg to memref<1x1x1x8xf64, strided<[64, 64, 8, 1], offset: ?>>
      memref_stream.streaming_region {
        patterns = [
          #memref_stream.stride_pattern<ub = [1, 1, 1, 2, 3, 3, 4], index_map = (d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, ((d2 * 2) + d4), (((d3 * 8) + (d6 * 2)) + d5))>,
          #memref_stream.stride_pattern<ub = [1, 1, 1, 2, 4], index_map = (d0, d1, d2, d3, d4) -> (d0, d1, d2, ((d3 * 4) + d4))>
        ]
      } ins(%X_subview_1 : memref<1x1x3x17xf64, strided<[324, 324, 18, 1], offset: ?>>) outs(%Y_subview_1 : memref<1x1x1x8xf64, strided<[64, 64, 8, 1], offset: ?>>) {
      ^bb0(%0 : !memref_stream.readable<f64>, %1 : !memref_stream.writable<f64>):
        %2 = arith.constant 2 : index
        %3 = arith.constant 0 : index
        %4 = arith.constant 1 : index
        %5 = arith.constant 9 : index
        %6 = builtin.unrealized_conversion_cast %3 : index to !riscv.reg
        %7 = builtin.unrealized_conversion_cast %2 : index to !riscv.reg
        %8 = builtin.unrealized_conversion_cast %4 : index to !riscv.reg
        riscv.parallel_mov : () -> ()
        riscv_scf.for %9 : !riscv.reg  = %6 to %7 step %8 {
          %10 = builtin.unrealized_conversion_cast %9 : !riscv.reg to index
          %11 = builtin.unrealized_conversion_cast %3 : index to !riscv.reg
          %12 = builtin.unrealized_conversion_cast %5 : index to !riscv.reg
          %13 = builtin.unrealized_conversion_cast %4 : index to !riscv.reg
          %min_val_1 = builtin.unrealized_conversion_cast %min_val : f64 to !riscv.freg
          %min_val_2 = builtin.unrealized_conversion_cast %min_val : f64 to !riscv.freg
          %min_val_3 = builtin.unrealized_conversion_cast %min_val : f64 to !riscv.freg
          %min_val_4 = builtin.unrealized_conversion_cast %min_val : f64 to !riscv.freg
          %14, %15, %16, %17 = riscv.parallel_mov %min_val_1, %min_val_2, %min_val_3, %min_val_4 : (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) -> (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg)
          %18, %19, %20, %21 = riscv_scf.for %22 : !riscv.reg  = %11 to %12 step %13 iter_args(%acc = %14, %acc_1 = %15, %acc_2 = %16, %acc_3 = %17) -> (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) {
            %acc_4 = builtin.unrealized_conversion_cast %acc_3 : !riscv.freg to f64
            %acc_5 = builtin.unrealized_conversion_cast %acc_2 : !riscv.freg to f64
            %acc_6 = builtin.unrealized_conversion_cast %acc_1 : !riscv.freg to f64
            %acc_7 = builtin.unrealized_conversion_cast %acc : !riscv.freg to f64
            %23 = builtin.unrealized_conversion_cast %22 : !riscv.reg to index
            %x = memref_stream.read from %0 : f64
            %x_1 = memref_stream.read from %0 : f64
            %x_2 = memref_stream.read from %0 : f64
            %x_3 = memref_stream.read from %0 : f64
            %res = arith.maximumf %x, %acc_7 : f64
            %res_1 = arith.maximumf %x_1, %acc_6 : f64
            %res_2 = arith.maximumf %x_2, %acc_5 : f64
            %res_3 = arith.maximumf %x_3, %acc_4 : f64
            %res_4 = builtin.unrealized_conversion_cast %res : f64 to !riscv.freg
            %res_5 = builtin.unrealized_conversion_cast %res_1 : f64 to !riscv.freg
            %res_6 = builtin.unrealized_conversion_cast %res_2 : f64 to !riscv.freg
            %res_7 = builtin.unrealized_conversion_cast %res_3 : f64 to !riscv.freg
            riscv_scf.yield %res_4, %res_5, %res_6, %res_7 : !riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg
          }
          %24, %25, %26, %27 = riscv.parallel_mov %18, %19, %20, %21 : (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg) -> (!riscv.freg, !riscv.freg, !riscv.freg, !riscv.freg)
          %28 = builtin.unrealized_conversion_cast %24 : !riscv.freg to f64
          %29 = builtin.unrealized_conversion_cast %25 : !riscv.freg to f64
          %30 = builtin.unrealized_conversion_cast %26 : !riscv.freg to f64
          %31 = builtin.unrealized_conversion_cast %27 : !riscv.freg to f64
          memref_stream.write %28 to %1 : f64
          memref_stream.write %29 to %1 : f64
          memref_stream.write %30 to %1 : f64
          memref_stream.write %31 to %1 : f64
        }
        riscv.parallel_mov : () -> ()
      }
    }
    riscv.parallel_mov : () -> ()
    func.return
  }
}
