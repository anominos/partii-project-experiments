build/mlir/module.ll: Makefile build/mlir/module.mlir
	mkdir -p build/mlir
	mlir-opt-20 build/mlir/module.mlir -convert-to-llvm | mlir-translate-20 --mlir-to-llvmir -o build/mlir/module.ll

build/mlir/module.s: Makefile build/mlir/module.ll
	mkdir -p build/mlir
	clang-21 -S -O1 --target=riscv64 -march=rv64gc -o build/mlir/module.s build/mlir/module.ll