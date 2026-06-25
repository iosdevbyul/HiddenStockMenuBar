//
//  StockManager.swift
//  StockMenuBar
//
//  Created by COMATOKI on 2026-06-25.
//

import Foundation
import Combine

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

enum DisguiseTheme: String, CaseIterable, Identifiable {
    case weather = "날씨"
    case excel = "엑셀"
    case clock = "시계"
    
    var id: String { self.rawValue }
}

class StockManager: ObservableObject {
    @Published var currentPrice: String = "0"
    // 프로퍼티 선언부 (초기값 제거 또는 기본값 유지)
    @Published var selectedTheme: DisguiseTheme = .weather {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "SavedSelectedTheme")
        }
    }
    @Published var allStocks: [StockItem] = []
    @Published var selectedStock: StockItem
    
    @Published var searchQuery: String = "" {
        didSet {
            performSearch()
        }
    }
    @Published var searchResults: [StockItem] = []
    
    private var timer: Timer?
    private let stockService: StockService
    private let allStocksKey = "SavedAllStocks"
    private let selectedStockKey = "SavedSelectedStock"
    
    var disguisedDisplayString: String {
        let cleanPrice = currentPrice.replacingOccurrences(of: ",", with: "")
        guard let priceNum = Double(cleanPrice), priceNum > 0 else {
            return "연결 중..."
        }
        
        switch selectedTheme {
        case .weather:
            let temperature = String(format: "%.2f", priceNum / 100.0)
            return "\(temperature)°C"
            
        case .excel:
            let priceInt = Int(priceNum)
            return "[\(priceInt)]"
            
        case .clock:
            let priceInt = Int(priceNum)
            let seconds = priceInt % 100
            let minutes = (priceInt / 100) % 100
            let hours = priceInt / 10000
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    init(stockService: StockService = NetworkStockService()) {
        self.stockService = stockService
        
        let defaultStocks = [
            StockItem(code: "000660", name: "SK하이닉스"),
            StockItem(code: "005930", name: "삼성전자")
        ]
        
        let defaultSelected = defaultStocks[0]
        self.selectedStock = defaultSelected
        
        loadFromUserDefaults(defaultStocks: defaultStocks, defaultSelected: defaultSelected)
        loadPrice()
        
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.loadPrice()
        }
        
        if let savedThemeRaw = UserDefaults.standard.string(forKey: "SavedSelectedTheme"),
           let savedTheme = DisguiseTheme(rawValue: savedThemeRaw) {
            self.selectedTheme = savedTheme
        }
    }
    
    private func performSearch() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            self.searchResults = []
            return
        }
        
        stockService.searchStock(keyword: query) { [weak self] results in
            DispatchQueue.main.async {
                self?.searchResults = results
            }
        }
    }
    
    func addStock(_ stock: StockItem) {
        selectStock(stock)
    }
    
    func selectStock(_ stock: StockItem) {
        var currentList = allStocks.filter { $0.code != stock.code }
        currentList.insert(stock, at: 0)
        
        if currentList.count > 3 {
            currentList.removeLast()
        }
        
        self.allStocks = currentList
        self.selectedStock = stock
        
        saveToUserDefaults()
        loadPrice()
    }
    
    func fetchStockPrice() {
        loadPrice()
    }
    
    private func loadPrice() {
        stockService.fetchStockPrice(stockCode: selectedStock.code) { [weak self] price in
            guard let price = price else { return }
            DispatchQueue.main.async {
                self?.currentPrice = price
            }
        }
    }
    
    private func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encodedAll = try? encoder.encode(allStocks) {
            UserDefaults.standard.set(encodedAll, forKey: allStocksKey)
        }
        if let encodedSelected = try? encoder.encode(selectedStock) {
            UserDefaults.standard.set(encodedSelected, forKey: selectedStockKey)
        }
    }
    
    private func loadFromUserDefaults(defaultStocks: [StockItem], defaultSelected: StockItem) {
        let decoder = JSONDecoder()
        
        if let savedAllData = UserDefaults.standard.data(forKey: allStocksKey),
           let decodedAll = try? decoder.decode([StockItem].self, from: savedAllData) {
            self.allStocks = decodedAll
        } else {
            self.allStocks = defaultStocks
        }
        
        if let savedSelectedData = UserDefaults.standard.data(forKey: selectedStockKey),
           let decodedSelected = try? decoder.decode(StockItem.self, from: savedSelectedData) {
            self.selectedStock = decodedSelected
        } else {
            self.selectedStock = defaultSelected
        }
    }
}
