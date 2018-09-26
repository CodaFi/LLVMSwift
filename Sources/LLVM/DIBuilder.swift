#if SWIFT_PACKAGE
import cllvm
#endif

/// A `DIBuilder` is a helper object used to generate debugging information in
/// the form of LLVM metadata.  A `DIBuilder` is usually paired with an
/// `IRBuilder` to allow for the generation of code and metadata in lock step.
public final class DIBuilder {
  internal let llvm: LLVMDIBuilderRef

  /// The module this `DIBuilder` is associated with.
  public let module: Module

  /// Initializes a new `DIBuilder` object.
  ///
  /// - Parameters:
  ///   - module: The parent module.
  ///   - allowUnresolved: If true, when this DIBuilder is finalized it will
  ///                      collect unresolved nodes attached to the module in
  ///                      order to resolve cycles
  public init(module: Module, allowUnresolved: Bool = true) {
    self.module = module
    if allowUnresolved {
      self.llvm = LLVMCreateDIBuilder(module.llvm)
    } else {
      self.llvm = LLVMCreateDIBuilderDisallowUnresolved(module.llvm)
    }
  }

  /// Construct any deferred debug info descriptors.
  public func finalize() {
    LLVMDIBuilderFinalize(self.llvm)
  }

  deinit {
    LLVMDisposeDIBuilder(self.llvm)
  }
}

extension DIBuilder {
  /// A CompileUnit provides an anchor for all debugging information generated
  /// during this instance of compilation.
  ///
  /// - Parameters:
  ///   - language: The source programming language.
  ///   - file: The file descriptor for the source file.
  ///   - kind: The kind of debug info to generate.
  ///   - optimized: A flag that indicates whether optimization is enabled or
  ///     not when compiling the source file.  Defaults to `false`.
  ///   - splitDebugInlining: A flag that indicates whether to emit inline debug
  ///     information.  Defaults to `false`.
  ///   - debugInfoForProfiling: A flag that indicates whether to emit extra
  ///     debug information for profile collection.
  ///   - flags: Command line options that are embedded in debug info for use
  ///     by third-party tools.
  ///   - splitName:
  ///   - identity: The identity of the tool that is compiling this source file.
  /// - Returns: A value representing a compilation-unit level scope.
  public func buildCompileUnit(
    for language: DWARFSourceLanguage,
    in file: FileMetadata,
    kind: DWARFEmissionKind,
    optimized: Bool = false,
    splitDebugInlining: Bool = false,
    debugInfoForProfiling: Bool = false,
    flags: [String] = [],
    runtimeVersion: Int,
    splitName: String = "",
    identity: String = ""
  ) -> CompileUnitMetadata {
    let allFlags = flags.joined(separator: " ")
    guard let cu = LLVMDIBuilderCreateCompileUnit(
      self.llvm, language.llvm, file.llvm, identity, identity.count,
      optimized.llvm,
      allFlags, allFlags.count,
      UInt32(runtimeVersion),
      splitName, splitName.count,
      kind.llvm,
      /*DWOId*/0,
      splitDebugInlining.llvm,
      debugInfoForProfiling.llvm
    ) else {
      fatalError()
    }
    return CompileUnitMetadata(llvm: cu)
  }

  /// Create a file descriptor to hold debugging information for a file.
  ///
  /// Global variables and top level functions would be defined using this
  /// context. File descriptors also provide context for source line
  /// correspondence.
  ///
  /// - Parameters:
  ///   - name: The name of the file.
  ///   - directory: The directory the file resides in.
  /// - Returns: A value represending metadata about a given file.
  public func buildFile(named name: String, in directory: String) -> FileMetadata {
    guard let file = LLVMDIBuilderCreateFile(
      self.llvm, name, name.count, directory, directory.count)
    else {
      fatalError("Failed to allocate metadata for a file")
    }
    return FileMetadata(llvm: file)
  }

  /// Creates a new descriptor for a module with the specified parent scope.
  ///
  /// - Parameters:
  ///   - parent: The parent scope containing this module declaration.
  ///   - name: Module name.
  ///   - macros: A list of -D macro definitions as they would appear on a
  ///             command line.
  ///   - includePath: The path to the module map file.
  ///   - includeSystemRoot: The Clang system root (value of -isysroot).
  public func buildModule(
    _ parent: DIScope, name: String,
    macros: [String] = [],
    includePath: String = "",
    includeSystemRoot: String = ""
  ) -> ModuleMetadata {
    let macros = macros.joined(separator: " ")
    guard
      let module = LLVMDIBuilderCreateModule(
        self.llvm, parent.asMetadata(), name, name.count,
        macros, macros.count, includePath, includePath.count,
        includeSystemRoot, includeSystemRoot.count)
    else {
      fatalError("Failed to allocate metadata for a file")
    }
    return ModuleMetadata(llvm: module)
  }

  /// Creates a new descriptor for a namespace with the specified parent scope.
  ///
  /// - Parameters:
  ///   - parent: The parent scope containing this module declaration.
  ///   - name: NameSpace name.
  ///   - exportSymbols: Whether or not the namespace exports symbols, e.g.
  ///                    this is true of C++ inline namespaces.
  public func buildNameSpace(_ parent: DIScope, name: String, exportSymbols: Bool) -> NameSpaceMetadata {
    guard
      let nameSpace = LLVMDIBuilderCreateNameSpace(
        self.llvm, parent.asMetadata(), name, name.count, exportSymbols.llvm)
    else {
      fatalError("Failed to allocate metadata for a file")
    }
    return NameSpaceMetadata(llvm: nameSpace)
  }

  /// Create a new descriptor for the specified subprogram.
  ///
  /// - Parameters:
  ///   - name: Function name.
  ///   - linkageName: Mangled function name.
  ///   - scope: Function scope.
  ///   - file: File where this variable is defined.
  ///   - line: Line number.
  ///   - scopeLine: Set to the beginning of the scope this starts
  ///   - type: Function type.
  ///   - flags: Flags to emit DWARF attributes.
  ///   - isLocal: True if this function is not externally visible.
  ///   - isDefinition: True if this is a function definition.
  ///   - isOptimized: True if optimization is enabled.
  public func buildFunction(
    named name: String, linkageName: String,
    scope: DIScope, file: FileMetadata, line: Int, scopeLine: Int,
    type: DISubroutineType,
    flags: DIFlags,
    isLocal: Bool = true, isDefinition: Bool = true,
    isOptimized: Bool = false
  ) -> FunctionMetadata {
    guard let fn = LLVMDIBuilderCreateFunction(
      self.llvm, scope.asMetadata(),
      name, name.count, linkageName, linkageName.count,
      file.asMetadata(), UInt32(line),
      type.asMetadata(),
      isLocal.llvm, isDefinition.llvm, UInt32(scopeLine),
      flags.llvm, isOptimized.llvm)
    else {
      fatalError("Failed to allocate metadata for a function")
    }
    return FunctionMetadata(llvm: fn)
  }

  /// Creates a new debug location that describes a source location.
  ///
  /// - Parameters:
  ///   - location: The location of the line and column for this information.
  ///               If the location of the value is unknown, pass
  ///               `(line: 0, column: 0)`.
  ///   - scope: The scope this debug location resides in.
  ///   - inlinedAt: If this location has been inlined somewhere, the scope in
  ///                which it was inlined.  Defaults to `nil`.
  /// - Returns: A value representing a debug location.
  public func buildDebugLocation(
    at location : (line: Int, column: Int),
    in scope: DIScope,
    inlinedAt: DIScope? = nil
  ) -> DebugLocation {
    guard let loc = LLVMDIBuilderCreateDebugLocation(
      self.module.context.llvm, UInt32(location.line), UInt32(location.column),
      scope.asMetadata(), inlinedAt?.asMetadata())
    else {
      fatalError("Failed to allocate metadata for a debug location")
    }
    return DebugLocation(llvm: loc)
  }
}

extension DIBuilder {
  /// Create subroutine type.
  ///
  /// - Parameters:
  ///   - file: The file in which the subroutine resides.
  ///   - parameters: An array of subroutine parameter types. This
  ///                        includes return type at 0th index.
  ///   - flags: Flags to emit DWARF attributes.
  public func buildSubroutineType(
    in file: FileMetadata, parameters: [DIType], flags: DIFlags = .zero
  ) -> DISubroutineType {
    var diTypes = parameters.map { $0.asMetadata() as Optional }
    return diTypes.withUnsafeMutableBufferPointer { buf in
      guard let ty = LLVMDIBuilderCreateSubroutineType(
        self.llvm, file.asMetadata(),
        buf.baseAddress!, UInt32(buf.count),
        flags.llvm)
      else {
          fatalError("Failed to allocate metadata")
      }
      return DISubroutineType(llvm: ty)
    }
  }

  /// Create a debugging information entry for an enumeration.
  ///
  /// - Parameters:
  ///   - name: Enumeration name.
  ///   - scope: Scope in which this enumeration is defined.
  ///   - file: File where this member is defined.
  ///   - line: Line number.
  ///   - size: Member size.
  ///   - alignmemnt: Member alignment.
  ///   - elements: Enumeration elements.
  ///   - numElements: Number of enumeration elements.
  ///   - underlyingType: Underlying type of a C++11/ObjC fixed enum.
  public func buildEnumerationType(
    named name: String,
    scope: DIScope, file: FileMetadata, line: Int,
    size: Size, alignment: Alignment,
    elements: [DIType], underlyingType: DIType
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    var diTypes = elements.map { $0.asMetadata() as Optional }
    return diTypes.withUnsafeMutableBufferPointer { buf in
      guard let ty = LLVMDIBuilderCreateEnumerationType(
        self.llvm, scope.asMetadata(),
        name, name.count, file.asMetadata(), UInt32(line),
        size.valueInBits(radix: UInt64(radix)), alignment.rawValue * radix,
        buf.baseAddress!, UInt32(buf.count),
        underlyingType.asMetadata())
      else {
        fatalError("Failed to allocate metadata")
      }
      return DIOpaqueType(llvm: ty)
    }
  }

  /// Create a debugging information entry for a union.
  ///
  /// - Parameters:
  ///   - name: Union name.
  ///   - scope: Scope in which this union is defined.
  ///   - file: File where this member is defined.
  ///   - line: Line number.
  ///   - size: Member size.
  ///   - alignment: Member alignment.
  ///   - flags: Flags to encode member attribute, e.g. private
  ///   - elements: Union elements.
  ///   - runtimeVersion: Optional parameter, Objective-C runtime version.
  ///   - uniqueID: A unique identifier for the union.
  public func buildUnionType(
    named name: String,
    scope: DIScope, file: FileMetadata, line: Int,
    size: Size, alignment: Alignment, flags: DIFlags,
    elements: [DIType],
    runtimeVersion: Int = 0, uniqueID: String = ""
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    var diTypes = elements.map { $0.asMetadata() as Optional }
    return diTypes.withUnsafeMutableBufferPointer { buf in
      guard let ty = LLVMDIBuilderCreateUnionType(
        self.llvm, scope.asMetadata(),
        name, name.count, file.asMetadata(), UInt32(line),
        size.valueInBits(radix: UInt64(radix)), alignment.rawValue * radix,
        flags.llvm, buf.baseAddress!, UInt32(buf.count),
        UInt32(runtimeVersion), uniqueID, uniqueID.count)
      else {
        fatalError("Failed to allocate metadata")
      }
      return DIOpaqueType(llvm: ty)
    }
  }

  /// Create a debugging information entry for an array.
  ///
  /// - Parameters:
  ///   - elementType: Metadata describing the type of the elements.
  ///   - size: The total size of the array.
  ///   - alignment: The alignment of the array.
  ///   - subscripts: A list of ranges of valid subscripts into the array.  For
  ///                 unbounded arrays, pass the unchecked range `-1...0`.
  public func buildArrayType(
    of elementType: DIType,
    size: Size, alignment: Alignment,
    subscripts: [Range<Int>] = []
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    var diSubs = subscripts.map {
      LLVMDIBuilderGetOrCreateSubrange(self.llvm, Int64($0.lowerBound), Int64($0.count))
    }
    return diSubs.withUnsafeMutableBufferPointer { buf in
      guard let ty = LLVMDIBuilderCreateArrayType(
        self.llvm, size.rawValue, alignment.rawValue * radix,
        elementType.asMetadata(),
        buf.baseAddress!, UInt32(buf.count))
      else {
        fatalError("Failed to allocate metadata")
      }
      return DIOpaqueType(llvm: ty)
    }
  }

  /// Create a debugging information entry for a vector.
  ///
  /// - Parameters:
  ///   - elementType: Metadata describing the type of the elements.
  ///   - size: The total size of the array.
  ///   - alignment: The alignment of the array.
  ///   - subscripts: A list of ranges of valid subscripts into the array.  For
  ///                 unbounded arrays, pass the unchecked range `-1...0`.
  public func buildVectorType(
    of elementType: DIType, size: Size, alignment: Alignment, subscripts: [Range<Int>] = []
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    var diSubs = subscripts.map {
      LLVMDIBuilderGetOrCreateSubrange(self.llvm, Int64($0.lowerBound), Int64($0.count))
    }
    return diSubs.withUnsafeMutableBufferPointer { buf in
      guard let ty = LLVMDIBuilderCreateVectorType(
        self.llvm, size.rawValue, alignment.rawValue * radix,
        elementType.asMetadata(),
        buf.baseAddress!, UInt32(buf.count))
      else {
        fatalError("Failed to allocate metadata")
      }
      return DIOpaqueType(llvm: ty)
    }
  }

  /// Create a debugging information entry for a DWARF unspecified type.
  ///
  /// Some languages have constructs in which a type may be left unspecified or the
  /// absence of a type may be explicitly indicated.  For example, C++ permits
  /// using the `auto` return type specifier for the return type of a member
  /// function declaration. The actual return type is deduced based on the
  /// definition of the function, so it may not be known when the function is
  /// declared. The language implementation can provide an unspecified type
  /// entry with the name `auto` which can be referenced by the return type
  /// attribute of a function declaration entry. When the function is later
  /// defined, the `subprogram` entry for the definition includes a reference to
  /// the actual return type.
  ///
  /// - Parameter name: The name of the type
  public func buildUnspecifiedType(named name: String) -> DIType {
    guard let ty = LLVMDIBuilderCreateUnspecifiedType(self.llvm, name, name.count) else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry for a basic type.
  ///
  /// - Parameters:
  ///   - name: Type name.
  ///   - type: The basic type encoding
  ///   - size: Size of the type.
  public func buildBasicType(
    named name: String, type: DIBasicTypeEncoding, size: Size
  ) -> DIType {
    let radix = UInt64(self.module.dataLayout.intPointerType().width)
    guard let ty = LLVMDIBuilderCreateBasicType(
      self.llvm, name, name.count, size.valueInBits(radix: radix), type.llvm)
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry for a pointer.
  ///
  /// - Parameters:
  ///   - pointee: Type pointed by this pointer.
  ///   - size: The size of the pointer value.
  ///   - alignment: The alignment of the pointer.
  ///   - addressSpace: DWARF address space.
  ///   - name: The name of the pointer type.
  public func buildPointerType(
    pointee: DIType, size: Size, alignment: Alignment = .zero,
    addressSpace: UInt32 = 0, name: String = ""
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    guard let ty = LLVMDIBuilderCreatePointerType(
      self.llvm, pointee.asMetadata(),
      size.valueInBits(radix: UInt64(radix)), alignment.rawValue * radix,
      addressSpace, name, name.count)
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry for a struct.
  ///
  /// - Parameters:
  ///   - name: Struct name.
  ///   - scope: Scope in which this struct is defined.
  ///   - file: File where this member is defined.
  ///   - line: Line number.
  ///   - size: The total size of the struct and its members.
  ///   - alignment: The alignment of the struct.
  ///   - flags: Flags to encode member attributes.
  ///   - elements: Struct elements.
  ///   - vtableHolder: The object containing the vtable for the struct.
  ///   - runtimeVersion: Optional parameter, Objective-C runtime version.
  ///   - uniqueId: A unique identifier for the struct.
  public func buildStructType(
    named name: String,
    scope: DIScope, file: FileMetadata, line: Int,
    size: Size, alignment: Alignment, flags: DIFlags = .zero,
    baseType: DIType? = nil, elements: [DIType] = [],
    vtableHolder: DIType? = nil, runtimeVersion: Int = 0, uniqueID: String = ""
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    var diEls = elements.map { $0.asMetadata() as Optional }
    return diEls.withUnsafeMutableBufferPointer { buf in
      guard let ty = LLVMDIBuilderCreateStructType(
        self.llvm, scope.asMetadata(), name, name.count, file.asMetadata(), UInt32(line),
        size.valueInBits(radix: UInt64(radix)), alignment.rawValue * radix, flags.llvm,
        baseType?.asMetadata(),
        buf.baseAddress!, UInt32(buf.count), UInt32(runtimeVersion),
        vtableHolder?.asMetadata(), uniqueID, uniqueID.count)
      else {
        fatalError("Failed to allocate metadata")
      }
      return DIOpaqueType(llvm: ty)
    }
  }

  /// Create a debugging information entry for a member.
  ///
  /// - Parameters:
  ///   - parentType: Parent type.
  ///   - scope: Member scope.
  ///   - name: Member name.
  ///   - file: File where this member is defined.
  ///   - line: Line number.
  ///   - size: Member size.
  ///   - alignment: Member alignment.
  ///   - offset: Member offset.
  ///   - flags: Flags to encode member attributes.
  public func buildMemberType(
    of parentType: DIType, scope: DIScope, name: String, file: FileMetadata,
    line: Int, size: Size, alignment: Alignment, offset: Size, flags: DIFlags = .zero
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    guard let ty = LLVMDIBuilderCreateMemberType(
      self.llvm, scope.asMetadata(), name, name.count, file.asMetadata(),
      UInt32(line),
      size.valueInBits(radix: UInt64(radix)), alignment.rawValue * radix, offset.rawValue,
      flags.llvm, parentType.asMetadata())
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry for a C++ static data member.
  ///
  /// - Parameters:
  ///   - parentType: Type of the static member.
  ///   - scope: Member scope.
  ///   - name: Member name.
  ///   - file: File where this member is declared.
  ///   - line: Line number.
  ///   - alignment: Member alignment.
  ///   - flags: Flags to encode member attributes.
  ///   - initialValue: Constant initializer of the member.
  public func buildStaticMemberType(
    of parentType: DIType, scope: DIScope, name: String, file: FileMetadata,
    line: Int, alignment: Alignment, flags: DIFlags = .zero,
    initialValue: IRConstant? = nil
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    guard let ty = LLVMDIBuilderCreateStaticMemberType(
      self.llvm, scope.asMetadata(), name, name.count, file.asMetadata(), UInt32(line),
      parentType.asMetadata(), flags.llvm, initialValue?.asLLVM(), alignment.rawValue * radix)
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry for a pointer to member.
  ///
  /// - Parameters:
  ///   - pointee: Type pointed to by this pointer.
  ///   - baseType: Type for which this pointer points to members of.
  ///   - size: Size.
  ///   - alignment: Alignment.
  ///   - flags: Flags.
  public func buildMemberPointerType(
    pointee: DIType, baseType: DIType, size: Size, alignment: Alignment, flags: DIFlags = .zero
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    guard let ty = LLVMDIBuilderCreateMemberPointerType(
      self.llvm, pointee.asMetadata(), baseType.asMetadata(),
      size.valueInBits(radix: UInt64(radix)), alignment.rawValue * radix, flags.llvm)
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a uniqued DIType* clone with FlagObjectPointer and
  /// FlagArtificial set.
  ///
  /// - Parameters:
  ///   - pointee: The underlying type to which this pointer points.
  public func buildObjectPointerType(pointee: DIType) -> DIType {
    guard let ty = LLVMDIBuilderCreateObjectPointerType(self.llvm, pointee.asMetadata()) else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry for a qualified type, e.g. 'const int'.
  ///
  /// - Parameters:
  ///   - tag: Tag identifying type.
  ///   - type: Base Type.
  public func buildQualifiedType(_ tag: DWARFTag, _ type: DIType) -> DIType {
    guard let ty = LLVMDIBuilderCreateQualifiedType(self.llvm, tag.rawValue, type.asMetadata()) else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry for a c++ style reference or rvalue
  /// reference type.
  ///
  /// - Parameters:
  ///   - tag: Tag identifying type.
  ///   - type: Base Type.
  public func buildReferenceType(_ tag: DWARFTag, _ type: DIType) -> DIType {
    guard let ty = LLVMDIBuilderCreateReferenceType(self.llvm, tag.rawValue, type.asMetadata()) else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create C++11 nullptr type.
  public func buildNullPtrType() -> DIType {
    guard let ty = LLVMDIBuilderCreateNullPtrType(self.llvm) else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }
}

extension DIBuilder {
  /// Create a debugging information entry for a typedef.
  ///
  /// - Parameters:
  ///   - type: Original type.
  ///   - name: Typedef name.
  ///   - scope: The surrounding context for the typedef.
  ///   - file: File where this type is defined.
  ///   - line: Line number.
  public func buildTypedef(
    of type: DIType, name: String, scope: DIScope, file: FileMetadata, line: Int
  ) -> DIType {
    guard let ty = LLVMDIBuilderCreateTypedef(self.llvm, type.asMetadata(), name, name.count, file.asMetadata(), UInt32(line), scope.asMetadata()) else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry to establish inheritance relationship
  /// between two types.
  ///
  /// - Parameters:
  ///   - derived: Original type.
  ///   - base: Base type. Ty is inherits from base.
  ///   - baseOffset: Base offset.
  ///   - virtualBasePointerOffset: Virtual base pointer offset.
  ///   - flags: Flags to describe inheritance attribute, e.g. private
  public func buildInheritance(
    of derived: DIType, to base: DIType,
    baseOffset: Size, virtualBasePointerOffset: Size, flags: DIFlags = .zero
  ) -> DIType {
    let radix = UInt64(self.module.dataLayout.intPointerType().width)
    guard let ty = LLVMDIBuilderCreateInheritance(
      self.llvm, derived.asMetadata(),
      base.asMetadata(),
      baseOffset.valueInBits(radix: radix),
      UInt32(virtualBasePointerOffset.valueInBits(radix: radix)),
      flags.llvm)
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a permanent forward-declared type.
  ///
  /// - Parameters:
  ///   - Tag: A unique tag for this type.
  ///   - Name: Type name.
  ///   - NameLen: Length of type name.
  ///   - Scope: Type scope.
  ///   - File: File where this type is defined.
  ///   - Line: Line number where this type is defined.
  ///   - RuntimeLang: Indicates runtime version for languages like
  ///                            Objective-C.
  ///   - SizeInBits: Member size.
  ///   - AlignInBits: Member alignment.
  ///   - UniqueIdentifier: A unique identifier for the type.
  ///   - UniqueIdentifierLen: Length of the unique identifier.
  public func buildForwardDeclaration(tag: DWARFTag, name: String, scope: DIScope, file: FileMetadata, line: Int, runtimeLanguage: Int, size: UInt64, alignment: UInt32, identifier: String) -> DIType {
    guard let ty = cllvm.LLVMDIBuilderCreateForwardDecl(self.llvm, tag.rawValue, name, name.count, scope.asMetadata(), file.asMetadata(), UInt32(line), UInt32(runtimeLanguage), size, alignment, identifier, identifier.count) else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a temporary forward-declared type.
  ///
  /// - Parameters:
  ///   - Tag: A unique tag for this type.
  ///   - Name: Type name.
  ///   - NameLen: Length of type name.
  ///   - Scope: Type scope.
  ///   - File: File where this type is defined.
  ///   - Line: Line number where this type is defined.
  ///   - RuntimeLang: Indicates runtime version for languages like
  ///                            Objective-C.
  ///   - SizeInBits: Member size.
  ///   - AlignInBits: Member alignment.
  ///   - Flags: Flags.
  ///   - UniqueIdentifier: A unique identifier for the type.
  ///   - UniqueIdentifierLen: Length of the unique identifier.
  public func buildReplaceableCompositeType(_ tag: DWARFTag, name: String, scope: DIScope, file: FileMetadata, line: Int, runtimeLanguage: Int, size: UInt64, alignment: UInt32, flags: DIFlags = .zero, identifier: String) -> DIType {
    guard let ty = LLVMDIBuilderCreateReplaceableCompositeType(
      self.llvm, tag.rawValue, name, name.count,
      scope.asMetadata(), file.asMetadata(), UInt32(line),
      UInt32(runtimeLanguage), size, alignment, flags.llvm,
      identifier, identifier.count)
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry for a bit field member.
  ///
  /// - Parameters:
  ///   - Scope: Member scope.
  ///   - Name: Member name.
  ///   - NameLen: Length of member name.
  ///   - File: File where this member is defined.
  ///   - LineNumber: Line number.
  ///   - SizeInBits: Member size.
  ///   - OffsetInBits: Member offset.
  ///   - StorageOffsetInBits: Member storage offset.
  ///   - Flags: Flags to encode member attribute.
  ///   - Type: Parent type.
  public func buildBitFieldMemberType(_ scope: DIScope, name: String, file: FileMetadata, line: Int, size: UInt64, offset: UInt64, storageOffset: UInt64, flags: DIFlags = .zero, type: DIType) -> DIType {
    guard let ty = LLVMDIBuilderCreateBitFieldMemberType(
      self.llvm, scope.asMetadata(), name, name.count,
      file.asMetadata(), UInt32(line), size, offset, storageOffset,
      flags.llvm, type.asMetadata())
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry for a class.
  ///   - name: Class name.
  ///   - baseType: Debug info of the base class of this type.
  ///   - scope: Scope in which this class is defined.
  ///   - file: File where this member is defined.
  ///   - line: Line number.
  ///   - size: Member size.
  ///   - alignment: Member alignment.
  ///   - offset: Member offset.
  ///   - flags: Flags to encode member attribute, e.g. private.
  ///   - elements: Class members.
  ///   - vtableHolder: Debug info of the base class that contains vtable
  ///                            for this type. This is used in
  ///                            DW_AT_containing_type. See DWARF documentation
  ///                            for more info.
  ///   - uniqueID: A unique identifier for the type.
  public func buildClassType(
    named name: String, derivedFrom baseType: DIType?,
    scope: DIScope, file: FileMetadata, line: Int,
    size: Size, alignment: Alignment, offset: Size, flags: DIFlags,
    elements: [DIType] = [],
    vtableHolder: DIType? = nil, uniqueID: String = ""
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    var diEls = elements.map { $0.asMetadata() as Optional }
    return diEls.withUnsafeMutableBufferPointer { buf in
      guard let ty = LLVMDIBuilderCreateClassType(
        self.llvm, scope.asMetadata(), name, name.count,
        file.asMetadata(), UInt32(line),
        size.valueInBits(radix: UInt64(radix)), alignment.rawValue * radix,
        offset.rawValue, flags.llvm,
        baseType?.asMetadata(),
        buf.baseAddress!, UInt32(buf.count),
        vtableHolder?.asMetadata(), nil, uniqueID, uniqueID.count)
      else {
        fatalError("Failed to allocate metadata")
      }
      return DIClassType(llvm: ty)
    }
  }

  /// Create a uniqued DIType* clone with FlagArtificial set.
  ///
  /// - Parameters:
  ///   - type: The underlying type.
  public func buildArtificialType(_ type: DIType) -> DIType {
    guard let ty = LLVMDIBuilderCreateArtificialType(self.llvm, type.asMetadata()) else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }
}

// MARK: Imported Entities

extension DIBuilder {
  /// Create a descriptor for an imported module.
  ///
  /// - Parameters:
  ///   - context: The scope this module is imported into
  ///   - namespace: The namespace being imported here.
  ///   - file: File where the declaration is located.
  ///   - line: Line number of the declaration.
  public func buildImportedModule(
    in context: DIScope, namespace: NameSpaceMetadata, file: FileMetadata, line: Int
  ) -> DIImportedEntity {
    guard let mod = LLVMDIBuilderCreateImportedModuleFromNamespace(
      self.llvm, context.asMetadata(), namespace.asMetadata(), file.asMetadata(), UInt32(line))
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIImportedEntity(llvm: mod)
  }

  /// Create a descriptor for an imported module.
  ///
  /// - Parameters:
  ///   - context: The scope this module is imported into.
  ///   - aliasee: An aliased namespace.
  ///   - file: File where the declaration is located.
  ///   - line: Line number of the declaration.
  public func buildImportedModule(
    in context: DIScope, aliasee: DIImportedEntity, file: FileMetadata, line: Int
  ) -> DIImportedEntity {
    guard let mod = LLVMDIBuilderCreateImportedModuleFromNamespace(
      self.llvm, context.asMetadata(), aliasee.asMetadata(), file.asMetadata(), UInt32(line))
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIImportedEntity(llvm: mod)
  }

  /// Create a descriptor for an imported module.
  ///
  /// - Parameters:
  ///   - context: The scope this module is imported into.
  ///   - module: The module being imported here
  ///   - file: File where the declaration is located.
  ///   - line: Line number of the declaration.
  public func buildImportedModule(
    in context: DIScope, module: ModuleMetadata, file: FileMetadata, line: Int
  ) -> DIImportedEntity {
    guard let mod = LLVMDIBuilderCreateImportedModuleFromModule(
      self.llvm, context.asMetadata(), module.asMetadata(), file.asMetadata(), UInt32(line))
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIImportedEntity(llvm: mod)
  }
  
  /// Create a descriptor for an imported function.
  ///
  /// - Parameters:
  ///   - context: The scope this module is imported into.
  ///   - declaration: The declaration (or definition) of a function, type, or
  ///                   variable.
  ///   - file: File where the declaration is located.
  ///   - line: Line number of the declaration.
  ///   - name: The name of the imported declaration.
  public func buildImportedDeclaration(
    in context: DIScope, declaration: Metadata, file: FileMetadata, line: Int, name: String = "") -> DIImportedEntity {
    guard let mod = LLVMDIBuilderCreateImportedDeclaration(
      self.llvm, context.asMetadata(),
      declaration.asMetadata(), file.asMetadata(), UInt32(line), name, name.count)
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIImportedEntity(llvm: mod)
  }
}

// MARK: Objective-C

extension DIBuilder {
  /// Create a debugging information entry for Objective-C instance variable.
  ///
  /// - Parameters:
  ///   - property: The property associated with this ivar.
  ///   - name: Member name.
  ///   - type: Type.
  ///   - file: File where this member is defined.
  ///   - line: Line number.
  ///   - size: Member size.
  ///   - alignment: Member alignment.
  ///   - offset: Member offset.
  ///   - flags: Flags to encode member attributes.
  public func buildObjCIVar(
    for property: DIObjCPropertyNode, name: String, type: DIType,
    file: FileMetadata, line: Int,
    size: Size, alignment: Alignment, offset: Size, flags: DIFlags = .zero
  ) -> DIType {
    let radix = UInt32(self.module.dataLayout.intPointerType().width)
    guard let ty = LLVMDIBuilderCreateObjCIVar(
      self.llvm, name, name.count, file.asMetadata(), UInt32(line),
      size.valueInBits(radix: UInt64(radix)), alignment.rawValue * radix,
      offset.rawValue, flags.llvm, type.asMetadata(), property.asMetadata())
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIOpaqueType(llvm: ty)
  }

  /// Create a debugging information entry for Objective-C property.
  ///
  /// - Parameters:
  ///   - name: Property name.
  ///   - type: Type.
  ///   - file: File where this property is defined.
  ///   - line: Line number.
  ///   - getter: Name of the Objective C property getter selector.
  ///   - setter: Name of the Objective C property setter selector.
  ///   - propertyAttributes: Objective C property attributes.
  public func buildObjCProperty(
    named name: String, type: DIType,
    file: FileMetadata, line: Int,
    getter: String, setter: String,
    propertyAttributes: ObjectiveCPropertyAttribute
  ) -> DIObjCPropertyNode {
    guard let ty = LLVMDIBuilderCreateObjCProperty(
      self.llvm, name, name.count, file.asMetadata(), UInt32(line),
      getter, getter.count, setter, setter.count,
      propertyAttributes.rawValue, type.asMetadata())
    else {
      fatalError("Failed to allocate metadata")
    }
    return DIObjCPropertyNode(llvm: ty)
  }
}
