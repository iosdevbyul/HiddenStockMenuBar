//
//  StockService.swift
//  StockMenuBar
//
//  Created by COMATOKI on 2026-06-25.
//

import Foundation

protocol StockService {
    func fetchStockPrice(stockCode: String, completion: @escaping (String?) -> Void)
    func searchStock(keyword: String, completion: @escaping ([StockItem]) -> Void)
}

class NetworkStockService: StockService {
    
    private struct NaverSearchResponse: Decodable {
        let items: [NaverStockItem]
    }
    
    private struct NaverStockItem: Decodable {
        let code: String
        let name: String
        let category: String
    }
    
    func fetchStockPrice(stockCode: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://m.stock.naver.com/api/stock/\(stockCode)/integration"
        guard let url = URL(string: urlString) else { completion(nil); return }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if error != nil { completion(nil); return }
            guard let data = data else { completion(nil); return }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let dealTrendInfos = json["dealTrendInfos"] as? [[String: Any]] {
                
                let targetInfo = dealTrendInfos.first { ($0["itemCode"] as? String) == stockCode }
                if let matchedInfo = targetInfo, let priceString = matchedInfo["closePrice"] as? String {
                    completion(priceString)
                    return
                }
            }
            completion(nil)
        }.resume()
    }
    
    func searchStock(keyword: String, completion: @escaping ([StockItem]) -> Void) {
        let cleanKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanKeyword.isEmpty else {
            completion([])
            return
        }
        
        guard let encodedKeyword = cleanKeyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://ac.stock.naver.com/ac?q=\(encodedKeyword)&target=stock%2Cipo%2Cindex%2Cmarketindicator") else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("https://finance.naver.com/", forHTTPHeaderField: "Referer")
        request.setValue("https://finance.naver.com", forHTTPHeaderField: "Origin")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(NaverSearchResponse.self, from: data)
                
                let filteredItems = response.items
                    .filter { $0.category == "stock" || $0.category == "ipo" }
                    .map { StockItem(code: $0.code, name: $0.name) }
                
                completion(filteredItems)
            } catch {
                completion([])
            }
        }.resume()
    }
}
