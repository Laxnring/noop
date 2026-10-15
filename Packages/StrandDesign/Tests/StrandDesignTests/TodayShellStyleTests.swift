import XCTest
@testable import StrandDesign

final class TodayShellStyleTests: XCTestCase {
    func testResolveExplicitLedger() {
        XCTAssertEqual(TodayShellStyle.resolve(raw: "ledger", legacyLiquidEnabled: true), .ledger)
    }

    func testResolveEmptyDefaultsLedgerWhenLegacyLiquidOn() {
        XCTAssertEqual(TodayShellStyle.resolve(raw: "", legacyLiquidEnabled: true), .ledger)
    }

    func testResolveEmptyLegacyOffIsClassic() {
        XCTAssertEqual(TodayShellStyle.resolve(raw: "", legacyLiquidEnabled: false), .classic)
    }

    func testResolveLiquidExplicit() {
        XCTAssertEqual(TodayShellStyle.resolve(raw: "liquid", legacyLiquidEnabled: false), .liquid)
    }
}
