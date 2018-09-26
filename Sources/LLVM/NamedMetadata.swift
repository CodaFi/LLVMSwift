#if SWIFT_PACKAGE
import cllvm
#endif

public class NamedMetadata {
  public let module: Module
  public let name: String

  init(module: Module, name: String) {
    self.module = module
    self.name = name
  }

  public var operands: [Metadata] {
    let count = Int(LLVMGetNamedMetadataNumOperands(self.module.llvm, name))
    let operands = UnsafeMutablePointer<LLVMValueRef?>.allocate(capacity: count)
    LLVMGetNamedMetadataOperands(self.module.llvm, name, operands)

    var ops = [Metadata]()
    ops.reserveCapacity(count)
    for i in 0..<count {
      guard let rawOperand = operands[i] else {
        continue
      }
      guard let metadata = LLVMValueAsMetadata(rawOperand) else {
        continue
      }
      ops.append(AnyMetadata(llvm: metadata))
    }
    return ops
  }

  public func addOperand(_ op: Metadata) {
    let metaVal = LLVMMetadataAsValue(self.module.context.llvm, op.asMetadata())
    LLVMAddNamedMetadataOperand(self.module.llvm, self.name, metaVal)
  }
}
