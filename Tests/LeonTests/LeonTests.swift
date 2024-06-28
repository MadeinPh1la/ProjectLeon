//
//  LeonTests.swift
//  LeonTests
//
//  Created by Kevin Downey on 1/18/24.
//

import XCTest
import Combine
import CoreML
@testable import Leon
 
enum MockError: Error {
    case mockError
}

struct MockResponse: Decodable {
    let key: String
}

class MockURLProtocol: URLProtocol {
    private var mockData: Data?
    private var mockResponse: URLResponse?
    private var mockError: Error?
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        self.mockData = nil
        self.mockResponse = nil
        self.mockError = nil
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }

    convenience init(data: Data?, response: URLResponse?, error: Error?) {
        self.init(request: URLRequest(url: URL(string: "https://example.com")!), cachedResponse: nil, client: nil)
        self.mockData = data
        self.mockResponse = response
        self.mockError = error
    }
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    override func startLoading() {
        if let error = mockError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            let response = mockResponse ?? URLResponse(url: URL(string: "https://example.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let mockData = mockData {
                client?.urlProtocol(self, didLoad: mockData)
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

// Conforming StockQuote to Equatable
extension StockQuote: Equatable {
    public static func == (lhs: StockQuote, rhs: StockQuote) -> Bool {
        return lhs.symbol == rhs.symbol &&
               lhs.open == rhs.open &&
               lhs.high == rhs.high &&
               lhs.low == rhs.low &&
               lhs.price == rhs.price &&
               lhs.volume == rhs.volume &&
               lhs.latestTradingDay == rhs.latestTradingDay &&
               lhs.previousClose == rhs.previousClose &&
               lhs.change == rhs.change &&
               lhs.changePercent == rhs.changePercent
    }
}

// Conforming CompanyOverview to Equatable
extension CompanyOverview: Equatable {
    public static func == (lhs: CompanyOverview, rhs: CompanyOverview) -> Bool {
        return lhs.symbol == rhs.symbol &&
               lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.marketCapitalization == rhs.marketCapitalization &&
               lhs.sharesOutstanding == rhs.sharesOutstanding
    }
}

//Conforming NewsArticle to Equatable
extension NewsArticle: Equatable, Hashable {
    public static func == (lhs: NewsArticle, rhs: NewsArticle) -> Bool {
        // Compare all properties except 'id'
        return lhs.banner_image == rhs.banner_image &&
               lhs.title == rhs.title &&
               lhs.url == rhs.url &&
               lhs.time_published == rhs.time_published &&
               lhs.summary == rhs.summary
    }

    public func hash(into hasher: inout Hasher) {
        // Hash all properties except 'id'
        hasher.combine(banner_image)
        hasher.combine(title)
        hasher.combine(url)
        hasher.combine(time_published)
        hasher.combine(summary)
    }
}

class LeonTests: XCTestCase {
    var viewModel: FinancialViewModel!
    var mockAPIService: MockAPIService!
    var mlModel: ProjectLeonRegressor_1!
    private var cancellables: Set<AnyCancellable>!
    var api: API!
    
    override func setUpWithError() throws {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mockAPIService = MockAPIService()
        setupMockAPIResponses()
        viewModel = FinancialViewModel(apiService: mockAPIService)
        mlModel = ProjectLeonRegressor_1()
        api = API.shared

        
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockAPIService = nil
        cancellables = nil
        mlModel = nil
        super.tearDown()
    }
    
    private func setupMockAPIResponses() {
        // Mock StockQuoteResponse
        let mockStockQuote = StockQuoteResponse(globalQuote: StockQuote(symbol: "AAPL", open: "150.00", high: "155.00", low: "149.00", price: "152.00", volume: "100000", latestTradingDay: "2023-03-16", previousClose: "150.00", change: "2.00", changePercent: "1.33%"))
        mockAPIService.mockStockQuoteResponse = Just(mockStockQuote)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Mock CompanyOverview
        let mockOverview = CompanyOverview(symbol: "AAPL", name: "Apple Inc.", description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide.", marketCapitalization: "2T", sharesOutstanding: "17B")
        mockAPIService.mockCompanyOverviewResponse = Just(mockOverview)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Mock CashFlowResponse
        let mockCashFlow = CashFlowResponse(symbol: "AAPL", annualReports: [
            CashFlowResponse.AnnualReport(
                fiscalDateEnding: "2020-09-30",
                reportedCurrency: "USD",
                operatingCashflow: "100000000",
                paymentsForOperatingActivities: "",
                proceedsFromOperatingActivities: nil,
                changeInOperatingLiabilities: "",
                changeInOperatingAssets: "",
                depreciationDepletionAndAmortization: "",
                capitalExpenditures: "-50000000",
                changeInReceivables: "",
                changeInInventory: "",
                profitLoss: "",
                cashflowFromInvestment: "",
                cashflowFromFinancing: "",
                proceedsFromRepaymentsOfShortTermDebt: "",
                paymentsForRepurchaseOfCommonStock: nil,
                paymentsForRepurchaseOfEquity: nil,
                paymentsForRepurchaseOfPreferredStock: nil,
                dividendPayout: "",
                dividendPayoutCommonStock: "",
                dividendPayoutPreferredStock: nil,
                proceedsFromIssuanceOfCommonStock: nil,
                proceedsFromIssuanceOfLongTermDebtAndCapitalSecuritiesNet: "",
                proceedsFromIssuanceOfPreferredStock: nil,
                proceedsFromRepurchaseOfEquity: "",
                proceedsFromSaleOfTreasuryStock: nil,
                changeInCashAndCashEquivalents: nil,
                changeInExchangeRate: nil,
                netIncome: "40000000"
            )
        ])
        mockAPIService.mockCashFlowResponse = Just(mockCashFlow)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Mock IncomeStatementData
        let mockIncomeStatement = IncomeStatementData(symbol: "AAPL", annualReports: [AnnualIncomeStatementReport(fiscalDateEnding: "2020-09-30", reportedCurrency: "USD", grossProfit: "98000000000", totalRevenue: "260000000000", operatingIncome: "66288000000", netIncome: "57411000000", ebit: "55000000000")])
        mockAPIService.mockIncomeStatementResponse = Just(mockIncomeStatement)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Mock BalanceSheetData
        let mockBalanceSheet = BalanceSheetData(symbol: "AAPL", annualReports: [AnnualBalanceSheetReport(fiscalDateEnding: "2020-09-30", reportedCurrency: "USD", totalAssets: "323000000000", totalCurrentAssets: "143000000000", cashAndCashEquivalentsAtCarryingValue: "38000000000", totalLiabilities: "100000000000", totalCurrentLiabilities: "105000000000", longTermDebt: "75000000000")])
        mockAPIService.mockBalanceSheetResponse = Just(mockBalanceSheet)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Mock NewsFeed
        let newsArticle1 = try? JSONDecoder().decode(NewsArticle.self, from: """
            {
                "banner_image": "https://example.com/image1.jpg",
                "title": "Article 1",
                "url": "https://example.com/article1",
                "time_published": "2023-03-16T10:00:00Z",
                "summary": "Summary of article 1"
            }
        """.data(using: .utf8)!)
        
        let newsArticle2 = try? JSONDecoder().decode(NewsArticle.self, from: """
            {
                "banner_image": "https://example.com/image2.jpg",
                "title": "Article 2",
                "url": "https://example.com/article2",
                "time_published": "2023-03-16T11:00:00Z",
                "summary": "Summary of article 2"
            }
        """.data(using: .utf8)!)
        
        let newsFeed = NewsFeed(items: "Some items", feed: [newsArticle1!, newsArticle2!])
        mockAPIService.mockNewsFeedResponse = Just(newsFeed)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Mock Trending Stocks
        let mockTopGainers: [Stock] = [
            Stock(ticker: "AAPL", price: "150.00", changeAmount: "2.00", changePercentage: "1.33%", volume: "100000"),
            Stock(ticker: "GOOGL", price: "2800.00", changeAmount: "50.00", changePercentage: "2.50%", volume: "200000")
        ]
        let mockTopLosers: [Stock] = [
            Stock(ticker: "MSFT", price: "300.00", changeAmount: "-2.00", changePercentage: "-0.66%", volume: "80000"),
            Stock(ticker: "AMZN", price: "3200.00", changeAmount: "-70.00", changePercentage: "-2.14%", volume: "150000")
        ]
        
        let trendingResponse = TrendingResponse(metadata: "Mock metadata", lastUpdated: "Mock last updated", topGainers: mockTopGainers, topLosers: mockTopLosers)
        
        mockAPIService.mockTrendingStocksResponse = Just(trendingResponse)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - View Model Tests
    
    func testDCFCalculation() {
        // Set up mock data
        let mockCashFlowData = CashFlowResponse(symbol: "AAPL", annualReports: [
            CashFlowResponse.AnnualReport(
                fiscalDateEnding: "2023-09-30",
                reportedCurrency: "USD",
                operatingCashflow: "110543000000",
                paymentsForOperatingActivities: "5703000000",
                proceedsFromOperatingActivities: nil,
                changeInOperatingLiabilities: "1142000000",
                changeInOperatingAssets: "7719000000",
                depreciationDepletionAndAmortization: "11519000000",
                capitalExpenditures: "-10959000000",
                changeInReceivables: "417000000",
                changeInInventory: "1618000000",
                profitLoss: "96995000000",
                cashflowFromInvestment: "3705000000",
                cashflowFromFinancing: "-108488000000",
                proceedsFromRepaymentsOfShortTermDebt: "-7956000000",
                paymentsForRepurchaseOfCommonStock: "77550000000",
                paymentsForRepurchaseOfEquity: "77550000000",
                paymentsForRepurchaseOfPreferredStock: nil,
                dividendPayout: "15025000000",
                dividendPayoutCommonStock: "15025000000",
                dividendPayoutPreferredStock: nil,
                proceedsFromIssuanceOfCommonStock: nil,
                proceedsFromIssuanceOfLongTermDebtAndCapitalSecuritiesNet: "5228000000",
                proceedsFromIssuanceOfPreferredStock: nil,
                proceedsFromRepurchaseOfEquity: "-77550000000",
                proceedsFromSaleOfTreasuryStock: nil,
                changeInCashAndCashEquivalents: "5760000000",
                changeInExchangeRate: nil,
                netIncome: "96995000000"
            )
        ])
        
        let mockIncomeStatementData = IncomeStatementData(symbol: "AAPL", annualReports: [
            AnnualIncomeStatementReport(
                fiscalDateEnding: "2023-09-30",
                reportedCurrency: "USD",
                grossProfit: "98000000000",
                totalRevenue: "260000000000",
                operatingIncome: "66288000000",
                netIncome: "57411000000",
                ebit: "55000000000"
            )
        ])
        
        let mockBalanceSheetData = BalanceSheetData(symbol: "AAPL", annualReports: [
            AnnualBalanceSheetReport(
                fiscalDateEnding: "2023-09-30",
                reportedCurrency: "USD",
                totalAssets: "352583000000",
                totalCurrentAssets: "143566000000",
                cashAndCashEquivalentsAtCarryingValue: "29965000000",
                totalLiabilities: "290437000000",
                totalCurrentLiabilities: "145308000000",
                longTermDebt: "105100000000"
            )
        ])
        
        // Set up the mock API service to return the mock data
        mockAPIService.mockCashFlowResponse = Just(mockCashFlowData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        mockAPIService.mockIncomeStatementResponse = Just(mockIncomeStatementData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        mockAPIService.mockBalanceSheetResponse = Just(mockBalanceSheetData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Create an instance of the FinancialViewModel with the mock API service
        let viewModel = FinancialViewModel(apiService: mockAPIService)
        viewModel.symbol = "AAPL"
        
        // Set the mock CompanyOverview data directly in the view model
        viewModel.companyOverview = CompanyOverview(
            symbol: "AAPL",
            name: "Apple Inc.",
            description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide.",
            marketCapitalization: "2000000000000",
            sharesOutstanding: "16070000000"
        )
        
        // Create an expectation for the DCF value
        let dcfValueExpectation = XCTestExpectation(description: "DCF value should be set")
        
        // Observe the dcfValue property
        let dcfValueCancellable = viewModel.$dcfValue
            .sink { dcfValue in
                if dcfValue != nil {
                    dcfValueExpectation.fulfill()
                }
            }
        
        // Call the loadDCFValue() method
        viewModel.loadDCFValue()
        
        // Wait for the expectation to be fulfilled
        wait(for: [dcfValueExpectation], timeout: 5.0)
        
        // Cancel the property observation
        dcfValueCancellable.cancel()
        
        // Call the updateSharePrice() method
        viewModel.updateSharePrice()
        
        // Use XCTAssert to verify the expected behavior and results
        XCTAssertNotNil(viewModel.dcfValue, "DCF value should not be nil after calculation")
        XCTAssertGreaterThan(viewModel.dcfValue ?? 0, 0, "DCF value should be greater than zero")
        XCTAssertNotNil(viewModel.dcfSharePrice, "DCF share price should not be nil after calculation")
        XCTAssertGreaterThan(viewModel.dcfSharePrice ?? 0, 0, "DCF share price should be greater than zero")
    }
    
    // MARK: - API Tests
    
    func testFetchFinancialDataWithNonEmptySymbolAndSuccessfulAPI() {
        // Given
        let symbol = "AAPL"
        let mockQuote = StockQuote(symbol: "AAPL",
                                   open: "150.00",
                                   high: "155.00",
                                   low: "145.00",
                                   price: "152.50",
                                   volume: "1000000",
                                   latestTradingDay: "2024-03-30",
                                   previousClose: "148.50",
                                   change: "4.00",
                                   changePercent: "2.7")
        let mockOverview = CompanyOverview(symbol: "AAPL", name: "Apple Inc.", description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide.", marketCapitalization: "2T", sharesOutstanding: "17B")
        mockAPIService.mockStockQuoteResponse = Just(StockQuoteResponse(globalQuote: mockQuote))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        mockAPIService.mockCompanyOverviewResponse = Just(mockOverview)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Create an expectation
        let expectation = XCTestExpectation(description: "Fetch financial data")
        
        // When
        viewModel.fetchFinancialData(forSymbol: symbol)
        
        // Wait for the quote to be updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then
            XCTAssertEqual(self.viewModel.quote?.symbol, mockQuote.symbol)
            // ... rest of the assertions ...
            
            // Fulfill the expectation
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled, or time out after 1 second
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testFetchFinancialDataWithEmptySymbol() {
        // Given
        let emptySymbol = ""
        
        // When
        viewModel.fetchFinancialData(forSymbol: emptySymbol)
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Error: Symbol is empty")
    }
    
    
    func testFetchStockQuoteSuccess() {
        let expectation = XCTestExpectation(description: "Fetch stock quote")
        
        mockAPIService.fetchStockQuote(forSymbol: "AAPL")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Failed with error: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { stockQuoteResponse in
                XCTAssertEqual(stockQuoteResponse.globalQuote.symbol, "AAPL", "The symbol should match.")
                XCTAssertEqual(stockQuoteResponse.globalQuote.price, "152.00", "The price should match.")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchCompanyOverviewSuccess() {
        let expectation = XCTestExpectation(description: "fetchCompanyOverview completes")
        
        mockAPIService.fetchCompanyOverview(forSymbol: "AAPL")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Request failed with error: \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { overview in
                XCTAssertEqual(overview.symbol, "AAPL")
                XCTAssertEqual(overview.name, "Apple Inc.")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchCashFlowDataSuccess() {
        let expectation = XCTestExpectation(description: "fetchCashFlowData completes")
        
        mockAPIService.fetchCashFlowData(forSymbol: "AAPL")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Request failed with error: \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { cashFlowResponse in
                XCTAssertNotNil(cashFlowResponse.annualReports.first)
                XCTAssertEqual(cashFlowResponse.symbol, "AAPL")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchIncomeStatementSuccess() {
        let expectation = XCTestExpectation(description: "fetchIncomeStatement completes")
        
        mockAPIService.fetchIncomeStatement(forSymbol: "AAPL")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Request failed with error: \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { incomeStatementData in
                XCTAssertNotNil(incomeStatementData.annualReports.first)
                XCTAssertEqual(incomeStatementData.symbol, "AAPL")
                XCTAssertEqual(incomeStatementData.annualReports.first?.netIncome, "57411000000")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchStockQuoteBadURL() {
        mockAPIService.mockStockQuoteResponse = nil
        
        let expectation = XCTestExpectation(description: "fetchStockQuote with bad URL completes")
        
        mockAPIService.fetchStockQuote(forSymbol: "AAPL")
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    XCTFail("Request should not succeed with a bad URL.")
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Request should not return a value with a bad URL.")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchStockQuoteUnauthorized() {
        mockAPIService.mockStockQuoteResponse = nil
        
        let expectation = XCTestExpectation(description: "fetchStockQuote with unauthorized access completes")
        
        mockAPIService.fetchStockQuote(forSymbol: "AAPL")
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    XCTFail("Request should not succeed with unauthorized access.")
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Request should not return a value with unauthorized access.")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchStockQuoteErrorMessage() {
        let expectedError = NSError(domain: "MockService", code: -1001, userInfo: nil)
        mockAPIService.mockStockQuoteResponse = Fail(error: expectedError).eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "fetchStockQuote with error message completes")
        
        mockAPIService.fetchStockQuote(forSymbol: "AAPL")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error as NSError, expectedError, "Error should match expected error.")
                    expectation.fulfill()
                } else {
                    XCTFail("Request should fail with an error.")
                }
            }, receiveValue: { _ in
                XCTFail("Request should not return a value with an error.")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStockQuoteDecoding() {
        let json = """
        {
            "Global Quote": {
                "01. symbol": "AAPL",
                "02. open": "150.00",
                "03. high": "155.00",
                "04. low": "149.00",
                "05. price": "154.00",
                "06. volume": "100000",
                "07. latest trading day": "2023-03-25",
                "08. previous close": "148.00",
                "09. change": "6.00",
                "10. change percent": "4.05%"
            }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(StockQuoteResponse.self, from: json)
            XCTAssertEqual(response.globalQuote.symbol, "AAPL")
            XCTAssertEqual(response.globalQuote.price, "154.00")
        } catch {
            XCTFail("Decoding failed: \(error)")
        }
    }
    
    func testLoadNewsFeedSuccess() {
        let expectation = XCTestExpectation(description: "Load news feed completes")
        
        mockAPIService.fetchNewsFeed(forSymbol: "AAPL")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Request failed with error: \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { newsFeed in
                XCTAssertEqual(newsFeed.feed.count, 2, "Number of news articles should match")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadNewsFeedUpdatesViewModel() {
        // Given
        let symbol = "AAPL"
        let expectedNewsArticlesCount = 2 // Directly set this based on your mock data setup
        
        // Create an expectation
        let expectation = XCTestExpectation(description: "News feed should be loaded into the view model")
        
        // When
        viewModel.loadNewsFeed(forSymbol: symbol)
        
        // Observe the viewModel's newsFeed property for changes
        let cancellable = viewModel.$newsFeed
            .sink { newsFeed in
                // Verify that the news feed is updated correctly
                XCTAssertEqual(newsFeed.count, expectedNewsArticlesCount, "News feed count should match the expected count")
                // Fulfill the expectation
                expectation.fulfill()
            }
        
        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 1.0)
        
        // Cancel the property observation
        cancellable.cancel()
    }
    
    
    func testLoadTrendingStocksSuccess() {
        let expectation = XCTestExpectation(description: "Load trending stocks completes")
        
        mockAPIService.fetchTrendingStocks()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Request failed with error: \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { response in
                XCTAssertEqual(response.topGainers.count, 2, "Number of top gainers should match")
                XCTAssertEqual(response.topLosers.count, 2, "Number of top losers should match")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorHandling() {
        
        
        mockAPIService.mockStockQuoteResponse = Fail(error: MockError.mockError).eraseToAnyPublisher()
        mockAPIService.mockCompanyOverviewResponse = Fail(error: MockError.mockError).eraseToAnyPublisher()
        
        // Set up expectation for error message being set
        let errorMessageExpectation = XCTestExpectation(description: "Error message should be set")
        
        // Observe the errorMessage property
        let errorMessageCancellable = viewModel.$errorMessage
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    XCTAssertEqual(errorMessage, "Failed to fetch data: The operation couldn’t be completed. (LeonTests.MockError error 0.)", "Error message did not match expected output")
                    errorMessageExpectation.fulfill()
                }
            }
        
        // Call the fetchFinancialData method
        viewModel.fetchFinancialData(forSymbol: "AAPL")
        
        // Wait for the expectation to be fulfilled
        wait(for: [errorMessageExpectation], timeout: 1.0)
        
        // Cancel the property observation
        errorMessageCancellable.cancel()
    }
    
    func testInvalidInputHandling() {
        // Set up expectation for error message being set
        let errorMessageExpectation = expectation(description: "Error message should be set")
        
        // Observe the errorMessage property
        let errorMessageCancellable = viewModel.$errorMessage
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    print("Received error message:", errorMessage)
                    XCTAssertEqual(errorMessage, "Error: Symbol is empty")
                    errorMessageExpectation.fulfill()
                    print("Expectation fulfilled")
                }
            }
        
        // Call the fetchFinancialData method with an empty symbol
        viewModel.fetchFinancialData(forSymbol: "")
        
        // Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 10) // Increased timeout
        
        // Cancel the property observation
        errorMessageCancellable.cancel()
    }
    
    func testFetchStockQuote() {
        // Given
        let symbol = "AAPL"
        let expectedQuote = StockQuote(symbol: "AAPL", open: "150.00", high: "155.00", low: "149.00", price: "152.00", volume: "100000", latestTradingDay: "2023-03-16", previousClose: "150.00", change: "2.00", changePercent: "1.33%")
        mockAPIService.mockStockQuoteResponse = Just(StockQuoteResponse(globalQuote: expectedQuote))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        let expectation = self.expectation(description: "Fetch stock quote")
        var receivedQuote: StockQuote?
        let cancellable = viewModel.fetchStockQuote(forSymbol: symbol)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { quote in
                receivedQuote = quote
            })
        
        // Then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(receivedQuote)
        XCTAssertEqual(receivedQuote, expectedQuote)
        cancellable.cancel()
    }
    
    func testFetchCompanyOverview() {
        // Given
        let symbol = "AAPL"
        let expectedOverview = CompanyOverview(symbol: "AAPL", name: "Apple Inc.", description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide.", marketCapitalization: "2T", sharesOutstanding: "17B")
        mockAPIService.mockCompanyOverviewResponse = Just(expectedOverview)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        let expectation = self.expectation(description: "Fetch company overview")
        var receivedOverview: CompanyOverview?
        let cancellable = viewModel.fetchCompanyOverview(forSymbol: symbol)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { overview in
                receivedOverview = overview
            })
        
        // Then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(receivedOverview)
        XCTAssertEqual(receivedOverview, expectedOverview)
        cancellable.cancel()
    }
    
    func testFetchStockQuoteWithMissingData() {
        // Given
        let symbol = "AAPL"
        let mockQuote = StockQuote(symbol: "AAPL", open: nil, high: nil, low: nil, price: nil, volume: nil, latestTradingDay: nil, previousClose: nil, change: nil, changePercent: nil)
        mockAPIService.mockStockQuoteResponse = Just(StockQuoteResponse(globalQuote: mockQuote))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        let expectation = self.expectation(description: "Fetch stock quote with missing data")
        var receivedQuote: StockQuote?
        let cancellable = viewModel.fetchStockQuote(forSymbol: symbol)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { quote in
                receivedQuote = quote
            })
        
        // Then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(receivedQuote)
        XCTAssertEqual(receivedQuote?.symbol, "AAPL")
        XCTAssertNil(receivedQuote?.open)
        XCTAssertNil(receivedQuote?.high)
        // Assert other properties are nil
        cancellable.cancel()
    }
    
    func testFetchCompanyOverviewWithInvalidData() {
        // Given
        let symbol = "AAPL"
        let invalidOverview = CompanyOverview(symbol: "AAPL", name: "", description: "", marketCapitalization: "Invalid", sharesOutstanding: "Invalid")
        mockAPIService.mockCompanyOverviewResponse = Just(invalidOverview)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        let expectation = self.expectation(description: "Fetch company overview with invalid data")
        var receivedOverview: CompanyOverview?
        let cancellable = viewModel.fetchCompanyOverview(forSymbol: symbol)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { overview in
                receivedOverview = overview
            })
        
        // Then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(receivedOverview)
        XCTAssertEqual(receivedOverview?.symbol, "AAPL")
        XCTAssertEqual(receivedOverview?.name, "")
        XCTAssertEqual(receivedOverview?.description, "")
        XCTAssertEqual(receivedOverview?.marketCapitalization, "Invalid")
        XCTAssertEqual(receivedOverview?.sharesOutstanding, "Invalid")
        cancellable.cancel()
    }
    
    func testFetchCashFlowDataWithMissingReports() {
        // Given
        let symbol = "AAPL"
        let mockCashFlow = CashFlowResponse(symbol: "AAPL", annualReports: [])
        mockAPIService.mockCashFlowResponse = Just(mockCashFlow)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        let expectation = self.expectation(description: "Fetch cash flow data with missing reports")
        var receivedCashFlowData: CashFlowResponse?
        let cancellable = mockAPIService.fetchCashFlowData(forSymbol: symbol)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { cashFlowData in
                receivedCashFlowData = cashFlowData
            })
        
        // Then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(receivedCashFlowData)
        XCTAssertEqual(receivedCashFlowData?.symbol, "AAPL")
        XCTAssertEqual(receivedCashFlowData?.annualReports.count, 0)
        cancellable.cancel()
    }
    
    // Test Model Prediction
    func testModelPrediction() throws {
        // Example input setup for the ML model, adjust types as necessary:
        let input = ProjectLeonRegressor_1Input(Volume: 100000, Stock: "HD", MA_20: 150.00, MA_50: 148.50,
                                                MA_200: 145.00, RSI: 70.00, MACD: 1.50, BB_Upper: 155.00,
                                                BB_Middle: 152.00, BB_Lower: 149.00, Prev_Close_1: 151.00,
                                                Prev_Close_7: 150.00, Prev_Close_30: 147.00)
        
        do {
            let prediction = try mlModel.prediction(input: input)
            // Assuming the output prediction is a single value, adjust as necessary:
            let predictedValue = prediction.featureValue(for: "Close")?.doubleValue ?? 0
            
            // Assert to check if the prediction is within an expected range or matches expected output
            XCTAssertEqual(predictedValue, 152.00, accuracy: 3.00, "Prediction does not match expected output")
        } catch {
            XCTFail("Model prediction failed: \(error)")
        }
    }
    
    // Test News Article decoding
    func testDecoding() throws {
        let json = """
        {
            "banner_image": "http://example.com/image.png",
            "title": "Test Article",
            "url": "http://example.com/article",
            "time_published": "2024-04-01T12:00:00Z",
            "summary": "A brief summary of the article."
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let article = try decoder.decode(NewsArticle.self, from: json)
        
        XCTAssertEqual(article.banner_image, "http://example.com/image.png")
        XCTAssertEqual(article.title, "Test Article")
        XCTAssertEqual(article.url, "http://example.com/article")
        XCTAssertEqual(article.time_published, "2024-04-01T12:00:00Z")
        XCTAssertEqual(article.summary, "A brief summary of the article.")
    }
    
    // Test News Article hashability
    
    func testHashability() {
        let article1 = NewsArticle(banner_image: "http://example.com/image1.png", title: "Same Article", url: "http://example.com", time_published: "2024-01-01T00:00:00Z", summary: "Test summary")
        let article2 = NewsArticle(banner_image: "http://example.com/image1.png", title: "Same Article", url: "http://example.com", time_published: "2024-01-01T00:00:00Z", summary: "Test summary")
        
        var articles = Set<NewsArticle>()
        articles.insert(article1)
        articles.insert(article2)
        
        XCTAssertEqual(articles.count, 1, "Articles should be considered the same and only one should be in the set.")
    }
    
    // Test article uniqueness
    func testIdentityUniqueness() throws {
        let jsonData1 = """
        {
            "banner_image": "http://example.com/image.png",
            "title": "Test Article",
            "url": "http://example.com/article",
            "time_published": "2024-04-01T12:00:00Z",
            "summary": "A brief summary of the article."
        }
        """.data(using: .utf8)!
        
        let jsonData2 = """
        {
            "banner_image": "http://example.com/image.png",
            "title": "Test Article",
            "url": "http://example.com/article",
            "time_published": "2024-04-01T12:00:00Z",
            "summary": "A brief summary of the article."
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let article1 = try decoder.decode(NewsArticle.self, from: jsonData1)
        let article2 = try decoder.decode(NewsArticle.self, from: jsonData2)
        
        XCTAssertNotEqual(article1.id, article2.id, "Each NewsArticle should have a unique id")
    }
    
    // Test NewsFeed rendering articles
    
    func testNewsFeedViewRendersArticles() {
        let view = NewsFeedView(symbol: "AAPL").environmentObject(viewModel)
        
        viewModel.loadNewsFeed(forSymbol: "AAPL")
        
        XCTAssertEqual(viewModel.newsFeed.count, 2, "Should display exactly 2 news articles")
    }
    
    func testFetchNewsFeed() {
        
        let symbol = "AAPL"
        let expectation = XCTestExpectation(description: "Fetch news feed")
        
        api.fetchNewsFeed(forSymbol: symbol)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Expected successful news feed fetch, but got error: \(error)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { newsFeed in
                
                XCTAssertNotNil(newsFeed)
                XCTAssertFalse(newsFeed.feed.isEmpty, "Expected non-empty news feed")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchHistoricalData() {
        // Given
        let symbol = "AAPL"
        let expectation = XCTestExpectation(description: "Fetch historical data")
        
        // When
        api.fetchHistoricalData(forSymbol: symbol)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Expected successful historical data fetch, but got error: \(error)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { historicalData in
                
                // Then
                XCTAssertFalse(historicalData.isEmpty)
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchBalanceSheet() {
        // Given
        let symbol = "AAPL"
        let expectation = XCTestExpectation(description: "Fetch balance sheet")
        
        // When
        api.fetchBalanceSheet(forSymbol: symbol)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Expected successful balance sheet fetch, but got error: \(error)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { balanceSheetData in
                // Then
                XCTAssertNotNil(balanceSheetData)
                XCTAssertFalse(balanceSheetData.annualReports.isEmpty)
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
}
