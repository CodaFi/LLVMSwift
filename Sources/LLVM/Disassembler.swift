#if !NO_SWIFTPM
import cllvm
#endif

public final class Disassembler {
  let llvm: LLVMDisasmContextRef

  public init(targeting tm: TargetMachine) {
    let cpu = tm.cpu
    let features = tm.features
    if !cpu.isEmpty && !features.isEmpty {
      self.llvm = LLVMCreateDisasmCPUFeatures(tm.triple, tm.cpu, tm.features, nil, 0, nil, nil)
    } else if features.isEmpty {
      self.llvm = LLVMCreateDisasmCPU(tm.triple, tm.cpu, nil, 0, nil, nil)
    } else {
      self.llvm = LLVMCreateDisasm(tm.triple, nil, 0, nil, nil)
    }
  }

  private func pprint(_ pos: Int, _ buf: UnsafeMutablePointer<UInt8>, _ len: Int, _ disasm: String) {
    print("\(String(pos, radix: 16, uppercase: true)):  ");
    for i in (0..<8) {
      if i < len {
        print("\(String(buf[i], radix: 16, uppercase: true)):  ");
      } else {
        print("   ", terminator: "");
      }
    }

    print("   \(disasm)");
  }

  public func disassemble(_ str: String) {
    return str.withCString { strBuf in
      guard let mutableBuf = strdup(strBuf) else {
        fatalError("Unable to duplicate buffer for disassembly!")
      }
      defer { free(mutableBuf) }
      let siz = strlen(mutableBuf)
      return mutableBuf.withMemoryRebound(to: UInt8.self, capacity: Int(siz)) { buf in
        var pos : Int = 0
        let outline = UnsafeMutablePointer<Int8>.allocate(capacity: 1024)
        while UInt(pos) < siz {
          let off = buf.advanced(by: Int(pos))
          let l : Int = LLVMDisasmInstruction(self.llvm, off, UInt64(siz - UInt(pos)), 0, outline, 1024)
          if l == 0 {
            pprint(pos, buf.advanced(by: pos), 1, "\t???")
            pos += 1
          } else {
            pprint(pos, buf.advanced(by: pos), l, String(validatingUTF8: UnsafePointer<CChar>(outline)) ?? "")
            pos += l
          }
        }
      }
    }
  }

  deinit {
    LLVMDisasmDispose(self.llvm)
  }
}
