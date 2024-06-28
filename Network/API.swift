//
//  API.swift
//  Leon
//
//  Created by Kevin Downey on 1/19/24.
//

import Foundation
import Combine

class API: APIService {
    static let shared = API()
    private let apiKey = "API Key"
    
    private init() {} // Singleton to prevent multiple instances
    
    // Implementation of fetchData adhering to APIService
    func fetchData<T: Decodable>(from url: URL, responseType: T.Type) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Response Status Code: \(httpResponse.statusCode)")
                }
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Data:\n\(jsonString)")
                } else {
                    print("Could not convert data to string")
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    // Fetch stock quote using Combine
    func fetchStockQuote(forSymbol symbol: String) -> AnyPublisher<StockQuoteResponse, Error> {
        guard let url = URL(string: "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(apiKey)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return fetchData(from: url, responseType: StockQuoteResponse.self)
    }
    
    // Fetch data for company overview using Combine
    func fetchCompanyOverview(forSymbol symbol: String) -> AnyPublisher<CompanyOverview, Error> {
        guard let url = URL(string: "https://www.alphavantage.co/query?function=OVERVIEW&symbol=\(symbol)&apikey=\(apiKey)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return fetchData(from: url, responseType: CompanyOverview.self)
    }
    
    // Fetch cash flow data using Combine
    public func fetchCashFlowData(forSymbol symbol: String) -> AnyPublisher<CashFlowResponse, Error> {
        let urlString = "https://www.alphavantage.co/query?function=CASH_FLOW&symbol=\(symbol)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return fetchData(from: url, responseType: CashFlowResponse.self)
    }
    
    // Fetch additional data points from company's Income Statement for DCF calculation
    public func fetchIncomeStatement(forSymbol symbol: String) -> AnyPublisher<IncomeStatementData, Error> {
        let urlString = "https://www.alphavantage.co/query?function=INCOME_STATEMENT&symbol=\(symbol)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return fetchData(from: url, responseType: IncomeStatementData.self)
    }
    
    // Fetch additional data points from company's balance sheet for an even more complete DCF calculation
    public func fetchBalanceSheet(forSymbol symbol: String) -> AnyPublisher<BalanceSheetData, Error> {
        let urlString = "https://www.alphavantage.co/query?function=BALANCE_SHEET&symbol=\(symbol)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return fetchData(from: url, responseType: BalanceSheetData.self)
    }
    
    // Fetch news
    func fetchNewsFeed(forSymbol symbol: String) -> AnyPublisher<NewsFeed, Error> {
        let urlString = "https://www.alphavantage.co/query?function=NEWS_SENTIMENT&symbol=\(symbol)&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: NewsFeed.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchTrendingStocks() -> AnyPublisher<TrendingResponse, Error> {
        guard let url = URL(string: "https://www.alphavantage.co/query?function=TOP_GAINERS_LOSERS&apikey=\(apiKey)&limit=2") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TrendingResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetchHistoricalData(forSymbol symbol: String) -> AnyPublisher<[Double], Error> {
        let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&apikey=\(apiKey)")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: AlphaVantageResponse.self, decoder: JSONDecoder())
            .map { response in
                response.timeSeriesDaily.values.map { $0.close }.compactMap(Double.init)
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
