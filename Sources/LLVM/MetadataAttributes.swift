#if SWIFT_PACKAGE
import cllvm
#endif

/// Source languages known by DWARF.
public enum DWARFSourceLanguage {
  case ada83

  case ada95

  case c

  case c89

  case c99

  case c11

  case cPlusPlus

  case cPlusPlus03

  case cPlusPlus11

  case cPlusPlus14

  case cobol74

  case cobol85

  case fortran77

  case fortran90

  case fortran03

  case fortran08

  case pascal83

  case modula2

  case java

  case fortran95

  case PLI

  case objC

  case objCPlusPlus

  case UPC

  case D

  case python

  case openCL

  case go

  case modula3

  case haskell

  case ocaml

  case rust

  case swift

  case julia

  case dylan

  case renderScript

  case BLISS

  // MARK: Vendor Extensions

  case mipsAssembler

  case googleRenderScript

  case borlandDelphi


  private static let languageMapping: [DWARFSourceLanguage: LLVMDWARFSourceLanguage] = [
    .c: LLVMDWARFSourceLanguageC, .c89: LLVMDWARFSourceLanguageC89,
    .c99: LLVMDWARFSourceLanguageC99, .c11: LLVMDWARFSourceLanguageC11,
    .ada83: LLVMDWARFSourceLanguageAda83,
    .cPlusPlus: LLVMDWARFSourceLanguageC_plus_plus,
    .cPlusPlus03: LLVMDWARFSourceLanguageC_plus_plus_03,
    .cPlusPlus11: LLVMDWARFSourceLanguageC_plus_plus_11,
    .cPlusPlus14: LLVMDWARFSourceLanguageC_plus_plus_14,
    .cobol74: LLVMDWARFSourceLanguageCobol74,
    .cobol85: LLVMDWARFSourceLanguageCobol85,
    .fortran77: LLVMDWARFSourceLanguageFortran77,
    .fortran90: LLVMDWARFSourceLanguageFortran90,
    .pascal83: LLVMDWARFSourceLanguagePascal83,
    .modula2: LLVMDWARFSourceLanguageModula2,
    .java: LLVMDWARFSourceLanguageJava,
    .ada95: LLVMDWARFSourceLanguageAda95,
    .fortran95: LLVMDWARFSourceLanguageFortran95,
    .PLI: LLVMDWARFSourceLanguagePLI,
    .objC: LLVMDWARFSourceLanguageObjC,
    .objCPlusPlus: LLVMDWARFSourceLanguageObjC_plus_plus,
    .UPC: LLVMDWARFSourceLanguageUPC,
    .D: LLVMDWARFSourceLanguageD,
    .python: LLVMDWARFSourceLanguagePython,
    .openCL: LLVMDWARFSourceLanguageOpenCL,
    .go: LLVMDWARFSourceLanguageGo,
    .modula3: LLVMDWARFSourceLanguageModula3,
    .haskell: LLVMDWARFSourceLanguageHaskell,
    .ocaml: LLVMDWARFSourceLanguageOCaml,
    .rust: LLVMDWARFSourceLanguageRust,
    .swift: LLVMDWARFSourceLanguageSwift,
    .julia: LLVMDWARFSourceLanguageJulia,
    .dylan: LLVMDWARFSourceLanguageDylan,
    .fortran03: LLVMDWARFSourceLanguageFortran03,
    .fortran08: LLVMDWARFSourceLanguageFortran08,
    .renderScript: LLVMDWARFSourceLanguageRenderScript,
    .BLISS: LLVMDWARFSourceLanguageBLISS,
    .mipsAssembler: LLVMDWARFSourceLanguageMips_Assembler,
    .googleRenderScript: LLVMDWARFSourceLanguageGOOGLE_RenderScript,
    .borlandDelphi: LLVMDWARFSourceLanguageBORLAND_Delphi,
    ]

  /// Retrieves the corresponding `LLVMDWARFSourceLanguage`.
  internal var llvm: LLVMDWARFSourceLanguage {
    return DWARFSourceLanguage.languageMapping[self]!
  }
}

public enum DWARFTag: UInt32 {
  case null = 0x0000
  case array_type = 0x0001
  case class_type = 0x0002
  case entry_point = 0x0003
  case enumeration_type = 0x0004
  case formal_parameter = 0x0005
  case imported_declaration = 0x0008
  case label = 0x000a
  case lexical_block = 0x000b
  case member = 0x000d
  case pointer_type = 0x000f
  case reference_type = 0x0010
  case compile_unit = 0x0011
  case string_type = 0x0012
  case structure_type = 0x0013
  case subroutine_type = 0x0015
  case typedef = 0x0016
  case union_type = 0x0017
  case unspecified_parameters = 0x0018
  case variant = 0x0019
  case common_block = 0x001a
  case common_inclusion = 0x001b
  case inheritance = 0x001c
  case inlined_subroutine = 0x001d
  case module = 0x001e
  case ptr_to_member_type = 0x001f
  case set_type = 0x0020
  case subrange_type = 0x0021
  case with_stmt = 0x0022
  case access_declaration = 0x0023
  case base_type = 0x0024
  case catch_block = 0x0025
  case const_type = 0x0026
  case constant = 0x0027
  case enumerator = 0x0028
  case file_type = 0x0029
  case friend = 0x002a
  case namelist = 0x002b
  case namelist_item = 0x002c
  case packed_type = 0x002d
  case subprogram = 0x002e
  case template_type_parameter = 0x002f
  case template_value_parameter = 0x0030
  case thrown_type = 0x0031
  case try_block = 0x0032
  case variant_part = 0x0033
  case variable = 0x0034
  case volatile_type = 0x0035
  // New in DWARF v3:
  case dwarf_procedure = 0x0036
  case restrict_type = 0x0037
  case interface_type = 0x0038
  case namespace = 0x0039
  case imported_module = 0x003a
  case unspecified_type = 0x003b
  case partial_unit = 0x003c
  case imported_unit = 0x003d
  case condition = 0x003f
  case shared_type = 0x0040
  // New in DWARF v4:
  case type_unit = 0x0041
  case rvalue_reference_type = 0x0042
  case template_alias = 0x0043
  // New in DWARF v5:
  case coarray_type = 0x0044
  case generic_subrange = 0x0045
  case dynamic_type = 0x0046
  case atomic_type = 0x0047
  case call_site = 0x0048
  case call_site_parameter = 0x0049
  case skeleton_unit = 0x004a
  case immutable_type = 0x004b
  // Vendor extensions:
  case MIPS_loop = 0x4081
  case format_label = 0x4101
  case function_template = 0x4102
  case class_template = 0x4103
  case GNU_template_template_param = 0x4106
  case GNU_template_parameter_pack = 0x4107
  case GNU_formal_parameter_pack = 0x4108
  case GNU_call_site = 0x4109
  case GNU_call_site_parameter = 0x410a
  case APPLE_property = 0x4200
  case BORLAND_property = 0xb000
  case BORLAND_Delphi_string = 0xb001
  case BORLAND_Delphi_dynamic_array = 0xb002
  case BORLAND_Delphi_set = 0xb003
  case BORLAND_Delphi_variant = 0xb004
}

public struct ObjectiveCPropertyAttribute : OptionSet {
  public let rawValue: UInt32

  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }

  public static let noattr            = ObjectiveCPropertyAttribute(rawValue: 0x00)
  public static let readonly          = ObjectiveCPropertyAttribute(rawValue: 0x01)
  public static let getter            = ObjectiveCPropertyAttribute(rawValue: 0x02)
  public static let assign            = ObjectiveCPropertyAttribute(rawValue: 0x04)
  public static let readwrite         = ObjectiveCPropertyAttribute(rawValue: 0x08)
  public static let retain            = ObjectiveCPropertyAttribute(rawValue: 0x10)
  public static let copy              = ObjectiveCPropertyAttribute(rawValue: 0x20)
  public static let nonatomic         = ObjectiveCPropertyAttribute(rawValue: 0x40)
  public static let setter            = ObjectiveCPropertyAttribute(rawValue: 0x80)
  public static let atomic            = ObjectiveCPropertyAttribute(rawValue: 0x100)
  public static let weak              = ObjectiveCPropertyAttribute(rawValue: 0x200)
  public static let strong            = ObjectiveCPropertyAttribute(rawValue: 0x400)
  public static let unsafe_unretained = ObjectiveCPropertyAttribute(rawValue: 0x800)
  public static let nullability       = ObjectiveCPropertyAttribute(rawValue: 0x1000)
  public static let null_resettable   = ObjectiveCPropertyAttribute(rawValue: 0x2000)
  public static let `class`           = ObjectiveCPropertyAttribute(rawValue: 0x4000)
}

public enum DIBasicTypeEncoding {
  case address
  case boolean
  case float
  case signed
  case signedChar
  case unsigned
  case unsignedChar

  private static let typeMapping: [DIBasicTypeEncoding: LLVMDWARFTypeEncoding] = [
    .address: 0,
    .boolean: 1,
    .float: 2,
    .signed: 3,
    .signedChar: 4,
    .unsigned: 5,
    .unsignedChar: 6,
    ]

  internal var llvm: LLVMDWARFTypeEncoding {
    return DIBasicTypeEncoding.typeMapping[self]!
  }
}

public struct DIFlags : OptionSet {
  public let rawValue: LLVMDIFlags.RawValue

  public init(rawValue: LLVMDIFlags.RawValue) {
    self.rawValue = rawValue
  }

  public static let zero                = DIFlags(rawValue: LLVMDIFlagZero.rawValue)
  public static let `private`           = DIFlags(rawValue: LLVMDIFlagPrivate.rawValue)
  public static let protected           = DIFlags(rawValue: LLVMDIFlagProtected.rawValue)
  public static let `public`            = DIFlags(rawValue: LLVMDIFlagPublic.rawValue)
  public static let forwardDeclaration  = DIFlags(rawValue: LLVMDIFlagFwdDecl.rawValue)
  public static let appleBlock          = DIFlags(rawValue: LLVMDIFlagAppleBlock.rawValue)
  public static let byrefStruct         = DIFlags(rawValue: LLVMDIFlagBlockByrefStruct.rawValue)
  public static let virtual             = DIFlags(rawValue: LLVMDIFlagVirtual.rawValue)
  public static let artificial          = DIFlags(rawValue: LLVMDIFlagArtificial.rawValue)
  public static let explicit            = DIFlags(rawValue: LLVMDIFlagExplicit.rawValue)
  public static let prototyped          = DIFlags(rawValue: LLVMDIFlagPrototyped.rawValue)
  public static let classComplete       = DIFlags(rawValue: LLVMDIFlagObjcClassComplete.rawValue)
  public static let objectPointer       = DIFlags(rawValue: LLVMDIFlagObjectPointer.rawValue)
  public static let vector              = DIFlags(rawValue: LLVMDIFlagVector.rawValue)
  public static let staticMember        = DIFlags(rawValue: LLVMDIFlagStaticMember.rawValue)
  public static let LValueReference     = DIFlags(rawValue: LLVMDIFlagLValueReference.rawValue)
  public static let RValueReference     = DIFlags(rawValue: LLVMDIFlagRValueReference.rawValue)
  public static let reserved            = DIFlags(rawValue: LLVMDIFlagReserved.rawValue)
  public static let singleInheritance   = DIFlags(rawValue: LLVMDIFlagSingleInheritance.rawValue)
  public static let multipleInheritance = DIFlags(rawValue: LLVMDIFlagMultipleInheritance.rawValue)
  public static let virtualInheritance  = DIFlags(rawValue: LLVMDIFlagVirtualInheritance.rawValue)
  public static let introducedVirtual   = DIFlags(rawValue: LLVMDIFlagIntroducedVirtual.rawValue)
  public static let bitField            = DIFlags(rawValue: LLVMDIFlagBitField.rawValue)
  public static let noReturn            = DIFlags(rawValue: LLVMDIFlagNoReturn.rawValue)
  public static let mainSubprogram      = DIFlags(rawValue: LLVMDIFlagMainSubprogram.rawValue)
  public static let passByValue         = DIFlags(rawValue: LLVMDIFlagTypePassByValue.rawValue)
  public static let passByReference     = DIFlags(rawValue: LLVMDIFlagTypePassByReference.rawValue)
  public static let fixedEnum           = DIFlags(rawValue: LLVMDIFlagFixedEnum.rawValue)
  public static let thunk               = DIFlags(rawValue: LLVMDIFlagThunk.rawValue)
  public static let trivial             = DIFlags(rawValue: LLVMDIFlagTrivial.rawValue)
  public static let indirectVirtualBase = DIFlags(rawValue: LLVMDIFlagIndirectVirtualBase.rawValue)
  public static let accessibility       = DIFlags(rawValue: LLVMDIFlagAccessibility.rawValue)
  public static let pointerToMemberRep  = DIFlags(rawValue: LLVMDIFlagPtrToMemberRep.rawValue)

  internal var llvm: LLVMDIFlags {
    return LLVMDIFlags(self.rawValue)
  }
}

/// The amount of debug information to emit.
public enum DWARFEmissionKind {
  case none
  case full
  case lineTablesOnly

  private static let emissionMapping: [DWARFEmissionKind: LLVMDWARFEmissionKind] = [
    .none: LLVMDWARFEmissionNone, .full: LLVMDWARFEmissionFull,
    .lineTablesOnly: LLVMDWARFEmissionLineTablesOnly,
    ]

  internal var llvm: LLVMDWARFEmissionKind {
    return DWARFEmissionKind.emissionMapping[self]!
  }
}
