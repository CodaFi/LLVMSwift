import LLVM
import XCTest
import Foundation

class DisassemblerSpec : XCTestCase {
  func testDisassembler() {
    let s = try! String(contentsOf: URL(fileURLWithPath: "/Users/cfi/Main"), encoding: .ascii)
    let t = try! TargetMachine(triple: "x86_64-apple-darwin10")
    let d = Disassembler(targeting: t)
    d.disassemble(s)
//    XCTAssert(fileCheckOutput(withPrefixes: ["DISASM"]) {
//
//    })
  }
}
