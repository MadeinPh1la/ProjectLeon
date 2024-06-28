//
//  MockAPIService.swift
//  LeonTests
//
//  Created by Kevin Downey on 3/16/24.
//

import Combine
import Foundation
@testable import Leon

enum MockAPIResponse<T> {
    case success(T)
    case failure(Error)
}

class MockAPIService: APIService {
    var mockStockQuoteResponse: AnyPublisher<StockQuoteResponse, Error>?
    var mockCompanyOverviewResponse: AnyPublisher<CompanyOverview, Error>?
    var mockCashFlowResponse: AnyPublisher<CashFlowResponse, Error>?
    var mockIncomeStatementResponse: AnyPublisher<IncomeStatementData, Error>?
    var mockBalanceSheetResponse: AnyPublisher<BalanceSheetData, Error>?
    var mockNewsFeedResponse: AnyPublisher<NewsFeed, Error>?
    var mockTrendingStocksResponse: AnyPublisher<TrendingResponse, Error>?
    
    func fetchData<T: Decodable>(from url: URL, responseType: T.Type) -> AnyPublisher<T, Error> {
        fatalError("fetchData should not be called directly in the mock.")
    }
    
    func fetchStockQuote(forSymbol symbol: String) -> AnyPublisher<StockQuoteResponse, Error> {
        return mockStockQuoteResponse ?? Fail(error: NSError(domain: "MockService", code: -1001, userInfo: nil)).eraseToAnyPublisher()
    }
    
    func fetchCompanyOverview(forSymbol symbol: String) -> AnyPublisher<CompanyOverview, Error> {
        return mockCompanyOverviewResponse ?? Fail(error: NSError(domain: "MockService", code: -1002, userInfo: nil)).eraseToAnyPublisher()
    }
    
    func fetchCashFlowData(forSymbol symbol: String) -> AnyPublisher<CashFlowResponse, Error> {
        return mockCashFlowResponse ?? Fail(error: NSError(domain: "MockService", code: -1002, userInfo: nil)).eraseToAnyPublisher()
    }
    
    func fetchIncomeStatement(forSymbol symbol: String) -> AnyPublisher<IncomeStatementData, Error> {
        return mockIncomeStatementResponse ?? Fail(error: NSError(domain: "MockService", code: -1002, userInfo: nil)).eraseToAnyPublisher()
    }
    
    func fetchBalanceSheet(forSymbol symbol: String) -> AnyPublisher<BalanceSheetData, Error> {
        return mockBalanceSheetResponse ?? Fail(error: NSError(domain: "MockService", code: -1002, userInfo: nil)).eraseToAnyPublisher()
    }
    
    func fetchNewsFeed(forSymbol symbol: String) -> AnyPublisher<NewsFeed, Error> {
        return mockNewsFeedResponse ?? Fail(error: URLError(.unsupportedURL)).eraseToAnyPublisher()
    }
    
    func fetchTrendingStocks() -> AnyPublisher<TrendingResponse, Error> {
        return mockTrendingStocksResponse ?? Fail(error: URLError(.unsupportedURL)).eraseToAnyPublisher()
    }
}
