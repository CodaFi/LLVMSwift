import LLVM
import LLVMIntrinsics
import XCTest
import Foundation
import FileCheck

class IRIntrinsicSpec : XCTestCase {
  func testIRIntrinsics() {
    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["IRINTRINSIC"]) {
      // IRINTRINSIC: ; ModuleID = '[[ModuleName:IRIntrinsicTest]]'
      // IRINTRINSIC-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRIntrinsicTest")
      let builder = IRBuilder(module: module)
      // IRINTRINSIC: define i32 @readOneArg(i32, ...) {
      let main = builder.addFunction("readOneArg",
                                     type: FunctionType(argTypes: [IntType.int32],
                                                        returnType: IntType.int32,
                                                        isVarArg: true))
      // IRINTRINSIC-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // IRINTRINSIC-NEXT: [[VA_BUF:%[0-9]+]] = alloca i8*
      let ap = builder.buildAlloca(type: PointerType(pointee: IntType.int8))
      // IRINTRINSIC-NEXT: [[CAST_VA_BUF:%[0-9]+]] = bitcast i8** [[VA_BUF]] to i8*
      let ap2 = builder.buildBitCast(ap, type: PointerType(pointee: IntType.int8))

      // IRINTRINSIC-NEXT: call void @llvm.va_start(i8* [[CAST_VA_BUF]])
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.llvm_va_start, args: ap2)

      // IRINTRINSIC-NEXT: [[RET_VAL:%[0-9]+]] = va_arg i8** [[VA_BUF]], i32
      let tmp = builder.buildVAArg(ap, type: IntType.int32)

      // IRINTRINSIC-NEXT: [[VA_COPY_BUF:%[0-9]+]] = alloca i8*
      let aq = builder.buildAlloca(type: PointerType(pointee: IntType.int8))
      // IRINTRINSIC-NEXT: [[CAST_VA_COPY_BUF:%[0-9]+]] = bitcast i8** [[VA_COPY_BUF]] to i8*
      let aq2 = builder.buildBitCast(aq, type: PointerType(pointee: IntType.int8))

      // IRINTRINSIC-NEXT: call void @llvm.va_copy(i8* [[CAST_VA_BUF]], i8* [[CAST_VA_COPY_BUF]])
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.llvm_va_copy, args: ap2, aq2)
      // IRINTRINSIC-NEXT: call void @llvm.va_end(i8* [[CAST_VA_COPY_BUF]])
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.llvm_va_end, args: aq2)

      // IRINTRINSIC-NEXT: call void @llvm.va_end(i8* [[CAST_VA_BUF]])
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.llvm_va_end, args: ap2)

      // IRINTRINSIC-NEXT: i32 [[RET_VAL]]
      builder.buildRet(tmp)
      // IRINTRINSIC-NEXT: }
      module.dump()

      // IRINTRINSIC: ; Function Attrs: nounwind
      // IRINTRINSIC-NEXT: declare void @llvm.va_start(i8*) #0

      // IRINTRINSIC: ; Function Attrs: nounwind
      // IRINTRINSIC-NEXT: declare void @llvm.va_copy(i8*, i8*) #0

      // IRINTRINSIC: ; Function Attrs: nounwind
      // IRINTRINSIC-NEXT: declare void @llvm.va_end(i8*) #0
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["VIRTUALOVERLOAD-IRINTRINSIC"]) {
      // VIRTUALOVERLOAD-IRINTRINSIC: ; ModuleID = '[[ModuleName:IRIntrinsicTest]]'
      // VIRTUALOVERLOAD-IRINTRINSIC-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRIntrinsicTest")
      let builder = IRBuilder(module: module)
      // VIRTUALOVERLOAD-IRINTRINSIC: define i32 @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: IntType.int32))
      // VIRTUALOVERLOAD-IRINTRINSIC-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      // VIRTUALOVERLOAD-IRINTRINSIC-NEXT: [[VAR_PTR:%[0-9]+]] = alloca i32
      let variable = builder.buildAlloca(type: IntType.int32)

      // VIRTUALOVERLOAD-IRINTRINSIC-NEXT: store i32 1, i32* [[VAR_PTR]]
      builder.buildStore(IntType.int32.constant(1), to: variable)

      // VIRTUALOVERLOAD-IRINTRINSIC-NEXT: [[COPY_PTR:%[0-9]+]] = call i32* @llvm.ssa_copy.p0i32(i32* %0)
      let cpyVar = builder.buildIntrinsicCall(to: GlobalIntrinsics.llvm_ssa_copy, args: variable)

      // VIRTUALOVERLOAD-IRINTRINSIC-NEXT: [[LOAD_VAR:%[0-9]+]] = load i32, i32* [[COPY_PTR]]
      let loadVar = builder.buildLoad(cpyVar)

      // VIRTUALOVERLOAD-IRINTRINSIC-NEXT:  ret i32 [[LOAD_VAR]]
      builder.buildRet(loadVar)
      // VIRTUALOVERLOAD-IRINTRINSIC-NEXT:  }
      module.dump()
    })

    XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["INTRINSIC-FAMILY-RESOLVE"]) {
      // INTRINSIC-FAMILY-RESOLVE: ; ModuleID = '[[ModuleName:IRIntrinsicTest]]'
      // INTRINSIC-FAMILY-RESOLVE-NEXT: source_filename = "[[ModuleName]]"
      let module = Module(name: "IRIntrinsicTest")
      let builder = IRBuilder(module: module)
      // INTRINSIC-FAMILY-RESOLVE: define i32 @main() {
      let main = builder.addFunction("main",
                                     type: FunctionType(argTypes: [],
                                                        returnType: IntType.int32))
      // INTRINSIC-FAMILY-RESOLVE-NEXT: entry:
      let entry = main.appendBasicBlock(named: "entry")
      builder.positionAtEnd(of: entry)

      let doubleAlloca = builder.buildAlloca(type: FloatType.double)
      builder.buildStore(FloatType.double.constant(1.0), to: doubleAlloca)
      let double = builder.buildLoad(doubleAlloca)

      let floatAlloca = builder.buildAlloca(type: FloatType.float)
      builder.buildStore(FloatType.float.constant(1.0), to: floatAlloca)
      let float = builder.buildLoad(floatAlloca)

      let halfAlloca = builder.buildAlloca(type: FloatType.half)
      builder.buildStore(FloatType.half.constant(1.0), to: halfAlloca)
      let half = builder.buildLoad(halfAlloca)

      // INTRINSIC-FAMILY-RESOLVE: call double @llvm.sin.f64(double
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_sin.self, args: double)
      // INTRINSIC-FAMILY-RESOLVE-NEXT: call double @llvm.cos.f64(double
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_cos.self, args: double)
      // INTRINSIC-FAMILY-RESOLVE-NEXT: call double @llvm.sqrt.f64(double
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_sqrt.self, args: double)
      // INTRINSIC-FAMILY-RESOLVE-NEXT: call double @llvm.log.f64(double
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_log.self, args: double)

      // INTRINSIC-FAMILY-RESOLVE-NEXT: call float @llvm.sin.f32(float
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_sin.self, args: float)
      // INTRINSIC-FAMILY-RESOLVE-NEXT: call float @llvm.cos.f32(float
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_cos.self, args: float)
      // INTRINSIC-FAMILY-RESOLVE-NEXT: call float @llvm.sqrt.f32(float
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_sqrt.self, args: float)
      // INTRINSIC-FAMILY-RESOLVE-NEXT: call float @llvm.log.f32(float
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_log.self, args: float)

      // INTRINSIC-FAMILY-RESOLVE-NEXT: call half @llvm.sin.f16(half
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_sin.self, args: half)
      // INTRINSIC-FAMILY-RESOLVE-NEXT: call half @llvm.cos.f16(half
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_cos.self, args: half)
      // INTRINSIC-FAMILY-RESOLVE-NEXT: call half @llvm.sqrt.f16(half
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_sqrt.self, args: half)
      // INTRINSIC-FAMILY-RESOLVE-NEXT: call half @llvm.log.f16(half
      _ = builder.buildIntrinsicCall(to: GlobalIntrinsics.int_log.self, args: half)

      builder.buildRet(IntType.int32.zero())
      module.dump()
    })
  }

  #if !os(macOS)
  static var allTests = testCase([
    ("testIRIntrinsics", testIRIntrinsics),
  ])
  #endif
}

