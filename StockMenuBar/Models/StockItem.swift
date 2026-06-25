//
//  StockItem.swift
//  StockMenuBar
//
//  Created by COMATOKI on 2026-06-25.
//

import Foundation

struct StockItem: Identifiable, Hashable, Codable {
    let id: UUID
    let code: String
    let name: String
    
    init(id: UUID = UUID(), code: String, name: String) {
        self.id = id
        self.code = code
        self.name = name
    }
}
