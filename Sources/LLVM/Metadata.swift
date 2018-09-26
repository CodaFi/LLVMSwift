#if SWIFT_PACKAGE
import cllvm
#endif

public protocol _IRMetadataInitializerHack {
  init(llvm: LLVMMetadataRef)
}

public protocol Metadata: _IRMetadataInitializerHack {
  func asMetadata() -> LLVMMetadataRef
}

extension Metadata {
  /// Replaces all uses of the this metadata with the given metadata.
  ///
  /// - parameter metadata: The new value to swap in.
  public func replaceAllUses(with metadata: Metadata) {
    LLVMMetadataReplaceAllUsesWith(self.asMetadata(), metadata.asMetadata())
  }
}

extension Metadata {
  public func forceCast<DestTy: Metadata>(to: DestTy.Type) -> DestTy {
    return DestTy(llvm: self.asMetadata())
  }
}

public protocol DIScope: Metadata {}

public protocol DIType: DIScope {}

extension DIType {
  var name: String {
    var length: Int = 0
    let cstring = LLVMDITypeGetName(self.asMetadata(), &length)
    return String(cString: cstring!)
  }

  var sizeIn: Size {
    return Size(LLVMDITypeGetSizeInBits(self.asMetadata()))
  }

  var offset: Size {
    return Size(LLVMDITypeGetOffsetInBits(self.asMetadata()))
  }

  var alignment: Alignment {
    return Alignment(LLVMDITypeGetAlignInBits(self.asMetadata()))
  }

  var line: Int {
    return Int(LLVMDITypeGetLine(self.asMetadata()))
  }

  var flags: DIFlags {
    return DIFlags(rawValue: LLVMDITypeGetFlags(self.asMetadata()).rawValue)
  }
}

struct AnyMetadata: Metadata {
  let llvm: LLVMMetadataRef

  func asMetadata() -> LLVMMetadataRef {
    return llvm
  }
}

public struct VariableMetadata: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct FileMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct CompileUnitMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct FunctionMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct ModuleMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct NameSpaceMetadata: DIScope {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct Macro: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct DIExpression: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}


public struct DebugLocation: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct DISubroutineType: DIType {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct DIOpaqueType: DIType {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct DIClassType: DIType {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct DIObjCPropertyNode: Metadata {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}

public struct DIImportedEntity: DIType {
  internal let llvm: LLVMMetadataRef

  public func asMetadata() -> LLVMMetadataRef {
    return llvm
  }

  public init(llvm: LLVMMetadataRef) {
    self.llvm = llvm
  }
}
