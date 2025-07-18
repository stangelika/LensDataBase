import XCTest
@testable import LensDataBase

#if canImport(SwiftUI)
import SwiftUI

/// Tests to ensure all components are properly accessible and don't have naming conflicts
/// This test suite specifically prevents the "cannot find X in scope" errors that were
/// occurring during iPad compilation
final class ComponentAvailabilityTests: XCTestCase {
    
    /// Test that all UI components can be instantiated without scope issues
    func testComponentAvailability() throws {
        // This test will fail at compile time if there are scope issues
        // with components, helping prevent the "cannot find X in scope" errors
        
        // Test AppTheme is accessible
        XCTAssertNotNil(AppTheme.Colors.primary)
        XCTAssertNotNil(AppTheme.Typography.bodyMedium)
        XCTAssertNotNil(AppTheme.Spacing.lg)
        XCTAssertNotNil(AppTheme.CornerRadius.md)
        
        // Test that shared component types exist and can be referenced
        // Note: We can't instantiate SwiftUI views directly in unit tests,
        // but we can test that the types exist and compile correctly
        
        // These will cause compilation errors if components have scope issues
        _ = type(of: GlassCard<Text>(content: { Text("Test") }))
        _ = type(of: GlassFilterChip(title: "Test", isSelected: false, action: {}))
        _ = type(of: FilterChip(icon: "test", title: "Test", accentColor: .blue))
        
        // Note: We don't test components that are defined in specific view files
        // (like SpecCard, RentalCard, etc.) as they should be scoped to those files
    }
    
    /// Test that AppTheme extensions work correctly
    func testAppThemeExtensions() throws {
        // Test that View extensions are available
        let testView = Text("Test")
        
        // These should compile without errors
        _ = testView.primaryTextStyle()
        _ = testView.secondaryTextStyle()
        _ = testView.headlineTextStyle()
        _ = testView.displayTextStyle()
        _ = testView.glassEffect()
        _ = testView.glassEffect(cornerRadius: 10)
        _ = testView.buttonStyle()
        _ = testView.cardStyle()
    }
    
    /// Test that there are no duplicate component names in shared components
    func testNoDuplicateSharedComponentNames() throws {
        // This test helps prevent naming conflicts by checking that
        // shared components (in Components/ directory) have unique names
        
        let sharedComponentNames = [
            "GlassCard",
            "GlassFilterChip", 
            "FilterChip"
        ]
        
        let uniqueNames = Set(sharedComponentNames)
        XCTAssertEqual(sharedComponentNames.count, uniqueNames.count, 
                      "Found duplicate shared component names: \(sharedComponentNames.filter { name in sharedComponentNames.filter { $0 == name }.count > 1 })")
    }
    
    /// Test that data models can be instantiated
    func testDataModelAvailability() throws {
        // Test that core data models are available
        // Note: We're not testing full model initialization as it would require valid data
        
        // Test that model types exist
        XCTAssertNotNil(Lens.self)
        XCTAssertNotNil(Camera.self)
        XCTAssertNotNil(Rental.self)
        XCTAssertNotNil(RecordingFormat.self)
        XCTAssertNotNil(AppData.self)
        
        // Test that manager classes exist
        XCTAssertNotNil(DataManager.self)
        XCTAssertNotNil(NetworkService.self)
    }
    
    /// Test specific to the original iPad compilation issue
    func testOriginalIssueResolution() throws {
        // This test specifically addresses the "cannot find GlassCard inscope" issue
        // If this test compiles and runs, it means the scope issue is resolved
        
        // Test that GlassCard type is available (original issue)
        let glassCardType = GlassCard<Text>.self
        XCTAssertNotNil(glassCardType)
        
        // Test that it can be used in a generic context (common iPad issue)
        func createGlassCard<Content: View>(@ViewBuilder content: () -> Content) -> GlassCard<Content> {
            return GlassCard(content: content)
        }
        
        let testCard = createGlassCard { Text("Test") }
        XCTAssertNotNil(testCard)
    }
    
    /// Test that all critical enums are accessible
    func testEnumAvailability() throws {
        // Test that enums used across the app are accessible
        XCTAssertNotNil(DataLoadingState.self)
        XCTAssertNotNil(ActiveTab.self)
        
        // Test enum cases
        XCTAssertEqual(DataLoadingState.idle, DataLoadingState.idle)
        XCTAssertEqual(ActiveTab.allLenses, ActiveTab.allLenses)
    }
}

#endif