func.func public @pooling_nchw_max_d1_s2_3x3(
    %X: memref<1x1x18x18xf64>,
    %Y: memref<1x1x8x8xf64>
) -> () {
    %min_val = arith.constant -10000 : f64
    linalg.generic {
        indexing_maps = [
            affine_map<(d0, d1, d2, d3) -> ()>,
            affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
        ],
        iterator_types = ["parallel", "parallel", "parallel", "parallel"]
    } ins(%min_val : f64) outs(%Y : memref<1x1x8x8xf64>) {
    ^bb0(%in: f64, %out: f64):
        linalg.yield %in : f64
    }
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<3x3xf32>
    linalg.generic {
      bounds = [#builtin.int<1>, #builtin.int<1>, #builtin.int<7>, #builtin.int<7>, #builtin.int<3>, #builtin.int<3>],
      indexing_maps = [
        affine_map<(d0, d1, d2, d3, d4, d5) -> (d0, d1, d2 * 2 + d4, d3 * 2 + d5)>,
        affine_map<(d0, d1, d2, d3, d4, d5) -> (d4, d5)>,
        affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
      ],
      iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction"]
    } ins(%X, %alloc : memref<1x1x18x18xf64>, memref<3x3xf32>) outs(%Y : memref<1x1x8x8xf64>) {
    ^bb0(%x : f64, %alloc_val: f64, %acc : f64):
      %res = arith.maximumf %x, %acc : f64
      linalg.yield %res : f64
    }
    memref.dealloc %alloc : memref<3x3xf32>
    func.return
  }



