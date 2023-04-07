; RUN: llc -mtriple=riscv64  -mattr=+xtheadba -mattr=+xtheadbb -mattr=+xtheadbs < %s | FileCheck %s -check-prefix=THEADC64


declare i32 @llvm.riscv.tstnbz.i32(i32 %a)

define i32 @tstnbz_w(i32 %a) nounwind {
  %tmp = call i32 @llvm.riscv.tstnbz.i32(i32 %a)
  ret i32 %tmp
}

declare i64 @llvm.riscv.tstnbz.i64(i64 %a)

define i64 @tstnbz_dw(i64 %a) nounwind {
  %tmp = call i64 @llvm.riscv.tstnbz.i64(i64 %a)
  ret i64 %tmp
}
