//
//  StockMenuBarUITests.swift
//  StockMenuBarUITests
//
//  Created by COMATOKI on 2026-06-25.
//

import XCTest

final class StockMenuBarUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        let menuBarItem = app.statusItems.firstMatch
        let exists = menuBarItem.waitForExistence(timeout: 5.0)
        XCTAssertTrue(exists, "메뉴바에 앱 아이콘/텍스트가 노출되지 않았습니다.")
        
        menuBarItem.click()
        
        let stockSelectionMenu = app.menuItems["종목 선택"]
        let menuExists = stockSelectionMenu.waitForExistence(timeout: 2.0)
        XCTAssertTrue(menuExists, "메뉴바를 클릭했을 때 드롭다운 메뉴가 열리지 않았습니다.")
    }
}
