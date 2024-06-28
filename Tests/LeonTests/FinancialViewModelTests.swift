//
//  FinancialViewModelTests.swift
//  LeonTests
//
//  Created by Kevin Downey on 3/14/24.
//


//import XCTest
//@testable import Leon
//import Combine
//
//class FinancialViewModelTests: XCTestCase {
//    var viewModel: FinancialViewModel!
//    var mockAPIService: MockAPIService!
//    private var cancellables: Set<AnyCancellable>!
//    
//    override func setUpWithError() throws {
//        super.setUp()
//        cancellables = []
//        mockAPIService = MockAPIService()
//        setupMockAPIResponses()
//        viewModel = FinancialViewModel(apiService: mockAPIService)
//    }
//    
//    override func tearDownWithError() throws {
//        viewModel = nil
//        mockAPIService = nil
//        cancellables = []
//        super.tearDown()
//    }
//    
//    private func setupMockAPIResponses() {
//        // Mock StockQuoteResponse
//        let mockStockQuote = StockQuoteResponse(globalQuote: StockQuote(symbol: "AAPL", open: "150.00", high: "155.00", low: "149.00", price: "152.00", volume: "100000", latestTradingDay: "2023-03-16", previousClose: "150.00", change: "2.00", changePercent: "1.33%"))
//        mockAPIService.mockStockQuoteResponse = Just(mockStockQuote)
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
//        
//        // Mock CompanyOverview
//        let mockOverview = CompanyOverview(symbol: "AAPL", name: "Apple Inc.", description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide.", marketCapitalization: "2T", sharesOutstanding: "17B")
//        mockAPIService.mockCompanyOverviewResponse = Just(mockOverview)
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
//        
//        // Mock CashFlowResponse
//        let mockCashFlow = CashFlowResponse(symbol: "AAPL", annualReports: [AnnualCashFlowReport(fiscalDateEnding: "2020-09-30", reportedCurrency: "USD", operatingCashflow: "50000000", capitalExpenditures: "-10000000", netIncome: "40000000")])
//        mockAPIService.mockCashFlowResponse = Just(mockCashFlow)
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
//        
//        // Mock IncomeStatementData
//        let mockIncomeStatement = IncomeStatementData(symbol: "AAPL", annualReports: [AnnualIncomeStatementReport(fiscalDateEnding: "2020-09-30", reportedCurrency: "USD", grossProfit: "98000000000", totalRevenue: "260000000000", operatingIncome: "66288000000", netIncome: "57411000000", ebit: "55000000000")])
//        mockAPIService.mockIncomeStatementResponse = Just(mockIncomeStatement)
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
//        
//        // Mock BalanceSheetData
//        let mockBalanceSheet = BalanceSheetData(symbol: "AAPL", annualReports: [AnnualBalanceSheetReport(fiscalDateEnding: "2020-09-30", reportedCurrency: "USD", totalAssets: "323000000000", totalCurrentAssets: "143000000000", cashAndCashEquivalentsAtCarryingValue: "38000000000", totalLiabilities: "100000000000", totalCurrentLiabilities: "105000000000", longTermDebt: "75000000000")])
//        mockAPIService.mockBalanceSheetResponse = Just(mockBalanceSheet)
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
//    }
//    
//    func testDCFCalculationCompletion() {
//        let expectation = XCTestExpectation(description: "DCF calculation completion")
//        
//        // Assuming viewModel has a method to initiate DCF calculation for a given symbol
//        viewModel.loadDCFValue(forSymbol: "AAPL")
//        
//        // Observe dcfSharePrice for changes as an indication of DCF calculation completion
//        let dcfSharePriceObservation = viewModel.$dcfSharePrice
//            .sink { dcfSharePrice in
//                XCTAssertNotNil(dcfSharePrice, "DCF share price should not be nil after DCF calculation")
//                // Optionally, verify against a specific expected value if applicable
//                // XCTAssertEqual(dcfSharePrice, expectedValue, "DCF share price did not match expected value")
//                
//                // Additional checks related to DCF calculation can be added here
//                // For example, verify that the calculated DCF share price is reasonable
//                
//                expectation.fulfill()
//            }
//        
//        // Hold the cancellable to avoid it being deallocated prematurely
//        cancellables.insert(dcfSharePriceObservation)
//        
//        // Wait for the expectation to be fulfilled, or time out after a reasonable duration
//        wait(for: [expectation], timeout: 20.0)
//    }
//}
