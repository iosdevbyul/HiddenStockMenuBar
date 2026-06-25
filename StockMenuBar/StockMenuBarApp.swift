//
//  StockMenuBarApp.swift
//  StockMenuBar
//
//  Created by COMATOKI on 2026-06-25.
//

import SwiftUI

@main
struct StockMenuBarApp: App {
    var body: some Scene {
        MenuBarExtra {
            Text("종목 선택")
            
            Divider()
            
            Button("종료") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Text("서울: 23.1°C")
        }
    }
}
