import XCTest
@testable import LensDataBase

final class FocalCategoryTests: XCTestCase {
    
    func testAllCategory() {
        let category = FocalCategory.all
        
        XCTAssertTrue(category.contains(focal: 10.0))
        XCTAssertTrue(category.contains(focal: 50.0))
        XCTAssertTrue(category.contains(focal: 200.0))
        XCTAssertTrue(category.contains(focal: 1000.0))
        XCTAssertFalse(category.contains(focal: nil))
    }
    
    func testUltraWideCategory() {
        let category = FocalCategory.ultraWide
        
        XCTAssertTrue(category.contains(focal: 8.0))
        XCTAssertTrue(category.contains(focal: 12.0))
        XCTAssertFalse(category.contains(focal: 13.0))
        XCTAssertFalse(category.contains(focal: 50.0))
        XCTAssertFalse(category.contains(focal: nil))
    }
    
    func testWideCategory() {
        let category = FocalCategory.wide
        
        XCTAssertFalse(category.contains(focal: 12.0))
        XCTAssertTrue(category.contains(focal: 13.0))
        XCTAssertTrue(category.contains(focal: 24.0))
        XCTAssertTrue(category.contains(focal: 35.0))
        XCTAssertFalse(category.contains(focal: 36.0))
        XCTAssertFalse(category.contains(focal: nil))
    }
    
    func testStandardCategory() {
        let category = FocalCategory.standard
        
        XCTAssertFalse(category.contains(focal: 35.0))
        XCTAssertTrue(category.contains(focal: 36.0))
        XCTAssertTrue(category.contains(focal: 50.0))
        XCTAssertTrue(category.contains(focal: 70.0))
        XCTAssertFalse(category.contains(focal: 71.0))
        XCTAssertFalse(category.contains(focal: nil))
    }
    
    func testTeleCategory() {
        let category = FocalCategory.tele
        
        XCTAssertFalse(category.contains(focal: 70.0))
        XCTAssertTrue(category.contains(focal: 71.0))
        XCTAssertTrue(category.contains(focal: 100.0))
        XCTAssertTrue(category.contains(focal: 180.0))
        XCTAssertFalse(category.contains(focal: 181.0))
        XCTAssertFalse(category.contains(focal: nil))
    }
    
    func testSuperTeleCategory() {
        let category = FocalCategory.superTele
        
        XCTAssertFalse(category.contains(focal: 180.0))
        XCTAssertTrue(category.contains(focal: 181.0))
        XCTAssertTrue(category.contains(focal: 300.0))
        XCTAssertTrue(category.contains(focal: 600.0))
        XCTAssertFalse(category.contains(focal: nil))
    }
    
    func testDisplayNames() {
        XCTAssertEqual(FocalCategory.all.displayName, "All")
        XCTAssertEqual(FocalCategory.ultraWide.displayName, "Ultra Wide (≤12mm)")
        XCTAssertEqual(FocalCategory.wide.displayName, "Wide (13–35mm)")
        XCTAssertEqual(FocalCategory.standard.displayName, "Standard (36–70mm)")
        XCTAssertEqual(FocalCategory.tele.displayName, "Tele (71–180mm)")
        XCTAssertEqual(FocalCategory.superTele.displayName, "Super Tele (181mm+)")
    }
    
    func testCaseIterable() {
        let allCases = FocalCategory.allCases
        XCTAssertEqual(allCases.count, 6)
        XCTAssertTrue(allCases.contains(.all))
        XCTAssertTrue(allCases.contains(.ultraWide))
        XCTAssertTrue(allCases.contains(.wide))
        XCTAssertTrue(allCases.contains(.standard))
        XCTAssertTrue(allCases.contains(.tele))
        XCTAssertTrue(allCases.contains(.superTele))
    }
    
    func testIdentifiable() {
        let category = FocalCategory.standard
        XCTAssertEqual(category.id, "standard")
    }
}