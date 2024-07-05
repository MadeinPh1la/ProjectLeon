//
//  APIService.swift
//  Leon
//
//  Created by Kevin Downey on 3/16/24.
//

import Combine
import Foundation

protocol APIService {
    func fetchData<T: Decodable>(from url: URL, responseType: T.Type) -> AnyPublisher<T, Error>
    func fetchStockQuote(forSymbol symbol: String) -> AnyPublisher<StockQuoteResponse, Error>
    func fetchCompanyOverview(forSymbol symbol: String) -> AnyPublisher<CompanyOverview, Error>
    func fetchCashFlowData(forSymbol symbol: String) -> AnyPublisher<CashFlowResponse, Error>
    func fetchIncomeStatement(forSymbol symbol: String) -> AnyPublisher<IncomeStatementData, Error>
    func fetchBalanceSheet(forSymbol symbol: String) -> AnyPublisher<BalanceSheetData, Error>
    func fetchNewsFeed(forSymbol symbol: String) -> AnyPublisher<NewsFeed, Error>
    func fetchTrendingStocks() -> AnyPublisher<TrendingResponse, Error>

}
