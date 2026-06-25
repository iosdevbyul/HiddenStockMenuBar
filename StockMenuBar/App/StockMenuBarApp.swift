//
//  StockMenuBarApp.swift
//  StockMenuBar
//
//  Created by COMATOKI on 2026-06-25.
//

import SwiftUI

@main
struct StockMenuBarApp: App {
    @StateObject private var stockManager: StockManager
    @State private var searchWindow: NSWindow? // 검색 창 참조 보관
    
    init() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_UI_TESTS"] == "1" {
            let mockService = MockStockService()
            _stockManager = StateObject(wrappedValue: StockManager(stockService: mockService))
        } else {
            _stockManager = StateObject(wrappedValue: StockManager())
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
            Text("종목 선택")
                .font(.caption)
            
            ForEach(stockManager.allStocks) { stock in
                Button(action: {
                    stockManager.selectStock(stock)
                }) {
                    HStack {
                        if stockManager.selectedStock.code == stock.code { Text("✓ ") }
                        Text(stock.name)
                    }
                }
            }
            
            // 실시간 주식 검색창 열기 버튼
            Button("+ 종목 검색 및 추가...") {
                openSearchWindow()
            }
            
            Divider()
            
            Text("위장 테마 선택")
                .font(.caption)
            ForEach(DisguiseTheme.allCases) { theme in
                Button(action: { stockManager.selectedTheme = theme }) {
                    HStack {
                        if stockManager.selectedTheme == theme { Text("✓ ") }
                        Text(theme.rawValue)
                    }
                }
            }
            
            Divider()
            Button("종료") { NSApplication.shared.terminate(nil) }
        } label: {
            Text(stockManager.disguisedDisplayString)
        }
    }
    
    // 네이티브 검색 창 띄우기
    private func openSearchWindow() {
        if searchWindow != nil {
            searchWindow?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let contentView = StockSearchView(manager: stockManager) {
            searchWindow?.close()
            searchWindow = nil
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        window.center()
        window.title = "종목 검색"
        window.contentView = NSHostingView(rootView: contentView)
        window.isReleasedWhenClosed = false
        
        self.searchWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// 실시간 검색 UI 뷰
struct StockSearchView: View {
    @ObservedObject var manager: StockManager
    var onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 검색 입력 필드
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("종목 이름 입력 (예: 카카오)", text: $manager.searchQuery)
                    .textFieldStyle(.plain)
                    .disableAutocorrection(true)
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // 검색 결과 리스트
            if manager.searchResults.isEmpty {
                VStack {
                    Spacer()
                    Text(manager.searchQuery.isEmpty ? "검색어를 입력하세요." : "검색 결과가 없습니다.")
                        .foregroundColor(.gray)
                        .font(.body)
                    Spacer()
                }
            } else {
                List(manager.searchResults) { stock in
                    Button(action: {
                        manager.addStock(stock)
                        manager.searchQuery = "" // 검색어 초기화
                        onSelect() // 창 닫기 콜백
                    }) {
                        HStack {
                            Text(stock.name)
                                .font(.body)
                            Spacer()
                            Text(stock.code)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 4)
                }
                .listStyle(.inset)
            }
        }
        .frame(width: 300, height: 400)
    }
}

// UI 테스트 대응용 패치 (프로토콜 준수용 선언)
class MockStockService: StockService {
    func fetchStockPrice(stockCode: String, completion: @escaping (String?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { completion("2,580,000") }
    }
    func searchStock(keyword: String, completion: @escaping ([StockItem]) -> Void) {
        completion([StockItem(code: "035720", name: "카카오")])
    }
}
