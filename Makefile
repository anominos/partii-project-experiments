build/mlir/module.ll: Makefile build/mlir/module.mlir
	mkdir -p build/mlir
	mlir-opt-20 build/mlir/module.mlir -convert-to-llvm | mlir-translate-20 --mlir-to-llvmir -o build/mlir/module.ll

build/mlir/module.s: Makefile build/mlir/module.ll
	mkdir -p build/mlir
	clang-21 -S -O1 --target=riscv64 -march=rv64gc -o build/mlir/module.s build/mlir/module.ll


build:
	mkdir -p build

output:
	mkdir -p output

.PHONY: all test-pmov clean test-perms test-spilling test-prealloc test-reorder
all: test-pmov test-perms test-spilling test-prealloc test-reorder

test-pmov: build output
	uv run test-pmov/test_pmov.py
	cp build/test-pmov-graph.svg output/test-pmov-graph.svg

test-perms: build output
	uv run test-pmov/test_invalid_permutations.py
	cp build/test-perms-graph-mvs.svg output/test-perms-graph-mvs.svg
	cp build/test-perms-graph-regs.svg output/test-perms-graph-regs.svg

test-spilling: build output
	uv run test-spilling/generate_spill.py
	cp build/test-spilling.svg output/test-spilling.svg

test-prealloc: build output
	uv run test-prealloc/test_prealloc.py
	cp build/test-prealloc.svg output/test-prealloc.svg

test-reorder: build output
	uv run test-reorder/test_reorder.py
	cp build/test-reorder.svg output/test-reorder.svg


clean:
	rm -rf build/*
	rm -rf output/*