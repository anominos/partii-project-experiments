func.func public @ssum(
  %X: memref<8x16xf32>,
  %Y: memref<8x16xf32>,
  %Z: memref<8x16xf32>
) {
  linalg.generic {
    indexing_maps = [
      affine_map<(d0, d1) -> (d0, d1)>,
      affine_map<(d0, d1) -> (d0, d1)>,
      affine_map<(d0, d1) -> (d0, d1)>
    ],
    iterator_types = ["parallel", "parallel"]
  } ins(%X, %Y : memref<8x16xf32>, memref<8x16xf32>) outs(%Z : memref<8x16xf32>) {
  ^bb1(%in : f32, %in_1 : f32, %out : f32):
    %3 = arith.addf %in, %in_1 : f32
    linalg.yield %3 : f32
  }
  func.return
}
