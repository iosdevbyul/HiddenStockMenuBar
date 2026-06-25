//
//  StockMenuBarUITests.swift
//  StockMenuBarUITests
//
//  Created by COMATOKI on 2026-06-25.
//

import XCTest

final class StockMenuBarUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launchEnvironment = ["XCODE_RUNNING_FOR_UI_TESTS": "1"]
        app.launch()

        let menuBarItem = app.statusItems["StockMenuBarItem"]
        let exists = menuBarItem.waitForExistence(timeout: 5.0)
        XCTAssertTrue(exists)
        
        menuBarItem.click()
        
        let excelMenuButton = app.menuItems["엑셀"]
        XCTAssertTrue(excelMenuButton.waitForExistence(timeout: 2.0))
        excelMenuButton.click()
        
        let updatedMenuBarItem = app.statusItems["StockMenuBarItem"]
        XCTAssertTrue(updatedMenuBarItem.waitForExistence(timeout: 2.0))
    }
}
