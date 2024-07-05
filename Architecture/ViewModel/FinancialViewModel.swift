//
//  FinancialViewModel.swift
//  Leon
//
//  Created by Kevin Downey on 1/19/24.
//

import FirebaseAuth
import Foundation
import Combine
import CoreML


class FinancialViewModel: ObservableObject {
    @Published var symbol: String = "" // Holds the symbol input by the user
    @Published var dcfSharePrice: Double? // Holds the calculated DCF share price
    @Published var quote: StockQuote? = nil
    @Published var stockQuoteState: DataState = .idle
    @Published var errorMessage: String? = nil
    @Published var companyOverview: CompanyOverview? = nil
    @Published var dcfValue: Double? = nil
    @Published var triggerUpdate: Bool = false
    @Published var sharePrice: Double? = nil
    @Published var newsFeed: [NewsArticle] = []
    @Published var trendingStocks: [Stock] = []
    @Published var topGainers: [Stock] = []
    @Published var topLosers: [Stock] = []
    @Published var readyToShowFinancialDetails = false
    @Published var predictedSharePrice: Double?
    
    var api: API
    var apiService: APIService
    var dcfModel = DCFModel()
    private let model: ProjectLeonRegressor_1
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: APIService) {
        self.apiService = apiService
        self.api = API.shared

        
        // Load the model file
        guard let modelURL = Bundle.main.url(forResource: "ProjectLeonRegressor_1", withExtension: "mlmodelc") else {
            fatalError("Failed to locate the model file.")
        }
        
        do {
            self.model = try ProjectLeonRegressor_1(contentsOf: modelURL)
        } catch {
            fatalError("Failed to load the model: \(error)")
        }
    }
    
    enum DataState {
        case idle, loading, loaded, error(String)
    }
        
    // Fetch financial data and compute predictions
    func fetchFinancialData(forSymbol symbol: String) {
        guard !symbol.isEmpty else {
            errorMessage = "Error: Symbol is empty"
            return
        }
        
        stockQuoteState = .loading

        let quotePublisher = fetchStockQuote(forSymbol: symbol)
        let overviewPublisher = fetchCompanyOverview(forSymbol: symbol)
        let historicalDataPublisher = api.fetchHistoricalData(forSymbol: symbol)

        // Combine all publishers
        Publishers.Zip3(quotePublisher, overviewPublisher, historicalDataPublisher)
            .flatMap { quote, overview, historicalData -> AnyPublisher<(StockQuote, CompanyOverview, Double?), Error> in
                // Calculate all indicators
                let sma20 = TechnicalIndicators.calculateSMA(data: historicalData, period: 20).last ?? 0
                let ema12 = TechnicalIndicators.calculateEMA(data: historicalData, period: 12).last ?? 0
                let ema26 = TechnicalIndicators.calculateEMA(data: historicalData, period: 26).last ?? 0
                let macd = TechnicalIndicators.calculateMACD(data: historicalData)
                let rsi = TechnicalIndicators.calculateRSI(data: historicalData).last ?? 0
                let (upperBand, _, lowerBand) = TechnicalIndicators.calculateBollingerBands(data: historicalData)
                let bbUpper = upperBand.last ?? 0
                let bbLower = lowerBand.last ?? 0
                let prevClose1 = historicalData.last ?? 0
                let prevClose7 = historicalData.count >= 7 ? historicalData[historicalData.count - 7] : 0
                let prevClose30 = historicalData.count >= 30 ? historicalData[historicalData.count - 30] : 0

                // Create the input for the model
                let input = ProjectLeonRegressor_1Input(
                    Volume: Int64(historicalData.last ?? 0.0),  // Convert volume to Int64
                    Stock: symbol,
                    MA_20: sma20,
                    MA_50: ema12,  // Assuming MA_50 to be ema12 for illustration
                    MA_200: ema26, // Assuming MA_200 to be ema26 for illustration
                    RSI: rsi,
                    MACD: macd.last ?? 0,
                    BB_Upper: bbUpper,
                    BB_Middle: (bbUpper + bbLower) / 2,
                    BB_Lower: bbLower,
                    Prev_Close_1: prevClose1,
                    Prev_Close_7: prevClose7,
                    Prev_Close_30: prevClose30
                )

                // Predict using the model
                do {
                    let predictionOutput = try self.model.prediction(input: input)
                    let predictedPrice = Double(predictionOutput.Close)
                    return Just((quote, overview, predictedPrice))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    print("Prediction error: \(error)")
                    return Just((quote, overview, nil))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                    self?.stockQuoteState = .error(error.localizedDescription)
                case .finished:
                    self?.stockQuoteState = .loaded
                }
            }, receiveValue: { [weak self] (quote, overview, predictedPrice) in
                self?.quote = quote
                self?.companyOverview = overview
                self?.predictedSharePrice = predictedPrice
                self?.readyToShowFinancialDetails = true
            })
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
    }
    
    
    func fetchStockQuote(forSymbol symbol: String) -> AnyPublisher<StockQuote, Error> {
        apiService.fetchStockQuote(forSymbol: symbol)
            .map { $0.globalQuote }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func fetchCompanyOverview(forSymbol symbol: String) -> AnyPublisher<CompanyOverview, Error> {
        apiService.fetchCompanyOverview(forSymbol: symbol)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    
    // Load the fetched DCF Value and update share price
    func loadDCFValue() {
        guard !self.symbol.isEmpty else {
            print("Error: Symbol is empty")
            return
        }
        stockQuoteState = .loading
        
        // Chain publishers for fetching Cash Flow, Income Statement, and Balance Sheet data
        let cashFlowPublisher = apiService.fetchCashFlowData(forSymbol: symbol).print("CashFlow")
        let incomeStatementPublisher = apiService.fetchIncomeStatement(forSymbol: symbol).print("IncomeStatement")
        let balanceSheetPublisher = apiService.fetchBalanceSheet(forSymbol: symbol).print("BalanceSheet")
        
        Publishers.Zip3(cashFlowPublisher, incomeStatementPublisher, balanceSheetPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to fetch financial data: \(error.localizedDescription)"
                    self?.stockQuoteState = .error(error.localizedDescription)
                    print("Error fetching financial data: \(error.localizedDescription)")
                } else {
                    self?.stockQuoteState = .loaded
                    print("Financial data fetched successfully.")
                }
            }, receiveValue: { [weak self] cashFlowData, incomeStatementData, balanceSheetData in
                guard let self = self else { return }
                print("Processing fetched financial data for DCF calculation...")
                
                guard let cashFlowReport = cashFlowData.annualReports.first,
                      let latestIncomeReport = incomeStatementData.annualReports.first,
                      let latestBalanceSheet = balanceSheetData.annualReports.first,
                      let operatingCashFlow = Double(cashFlowReport.operatingCashflow),
                      let capitalExpenditures = Double(cashFlowReport.capitalExpenditures) else {
                    print("Error: Latest financial reports not found or data missing.")
                    return
                }
                
                let freeCashFlow = operatingCashFlow - capitalExpenditures
                
                guard let netIncome = Double(latestIncomeReport.netIncome),
                      let longTermDebt = Double(latestBalanceSheet.longTermDebt),
                      let cashAndEquivalents = Double(latestBalanceSheet.cashAndCashEquivalentsAtCarryingValue) else {
                    print("Error converting financial data to Double.")
                    return
                }
                
                // Perform DCF calculation using your dcfModel's method, ensure it accepts the correct parameters
                let calculatedDCFValue = self.dcfModel.calculateDCF(
                    freeCashFlow: freeCashFlow,
                    netIncome: netIncome,
                    longTermDebt: longTermDebt,
                    cashAndEquivalents: cashAndEquivalents
                )
                
                print("Calculated DCF Value: \(calculatedDCFValue)")
                self.dcfValue = calculatedDCFValue
                
                // After successfully calculating the DCF value, call updateSharePrice to calculate and update the share price
                self.updateSharePrice()
            })
            .store(in: &cancellables)
    }
        
    // Update DCF share price with calculated value
    func updateSharePrice() {
        guard let dcfValue = dcfValue,
              let sharesOutstandingStr = companyOverview?.sharesOutstanding,
              let sharesOutstanding = Double(sharesOutstandingStr),
              sharesOutstanding > 0 else {
            print("Error: DCF value not calculated or invalid shares outstanding.")
            return
        }

        
        let calculatedDcfSharePrice = dcfValue / sharesOutstanding
        print("Updated DCF Share Price: \(calculatedDcfSharePrice)")
        // Update the @Published property that your UI observes
        self.dcfSharePrice = calculatedDcfSharePrice
    }
    
    
    // Predicts the share price for a given stock symbol
    func predictSharePrice(forSymbol symbol: String) -> AnyPublisher<Double?, Never> {
        // Fetch historical data from the API
        api.fetchHistoricalData(forSymbol: symbol)
            .flatMap { historicalData -> AnyPublisher<Double?, Never> in
                // Ensure there is enough data to calculate the indicators
                guard historicalData.count >= 200 else {
                    return Just(nil).eraseToAnyPublisher()
                }

                // Calculate technical indicators
                let sma20 = TechnicalIndicators.calculateSMA(data: historicalData, period: 20).last ?? 0
                let sma50 = TechnicalIndicators.calculateSMA(data: historicalData, period: 50).last ?? 0
                let sma200 = TechnicalIndicators.calculateSMA(data: historicalData, period: 200).last ?? 0
                let rsi = TechnicalIndicators.calculateRSI(data: historicalData).last ?? 0
                let macd = TechnicalIndicators.calculateMACD(data: historicalData).last ?? 0
                let (upperBand, middleBand, lowerBand) = TechnicalIndicators.calculateBollingerBands(data: historicalData)
                let bbUpper = upperBand.last ?? 0
                let bbMiddle = middleBand.last ?? 0
                let bbLower = lowerBand.last ?? 0
                let prevClose1 = historicalData.last ?? 0
                let prevClose7 = historicalData.count >= 7 ? historicalData[historicalData.count - 7] : 0
                let prevClose30 = historicalData.count >= 30 ? historicalData[historicalData.count - 30] : 0

                // Create model input using the calculated indicators
                let input = ProjectLeonRegressor_1Input(
                    Volume: Int64(historicalData.last ?? 0.0),  // Convert volume to Int64
                    Stock: symbol,
                    MA_20: sma20,
                    MA_50: sma50,
                    MA_200: sma200,
                    RSI: rsi,
                    MACD: macd,
                    BB_Upper: bbUpper,
                    BB_Middle: bbMiddle,
                    BB_Lower: bbLower,
                    Prev_Close_1: prevClose1,
                    Prev_Close_7: prevClose7,
                    Prev_Close_30: prevClose30
                )

                // Use the model to predict the price
                do {
                    let prediction = try self.model.prediction(input: input)
                    let predictedPrice = Double(prediction.Close)  // Assuming 'Close' is the output feature name
                    return Just(predictedPrice).eraseToAnyPublisher()
                } catch {
                    print("Error in prediction: \(error)")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .catch { _ in Just(nil).eraseToAnyPublisher() }  // Handle any errors
            .eraseToAnyPublisher()  // Ensure it returns the expected publisher type
    }

        
    // Fetch news feed
    
    func loadNewsFeed(forSymbol symbol: String) {
        apiService.fetchNewsFeed(forSymbol: symbol)
            .sink(receiveCompletion: { completion in
                print(completion) // Debug completion
            }, receiveValue: { [weak self] newsFeed in
                self?.newsFeed = newsFeed.feed
                print("News feed updated with \(newsFeed.feed.count) articles.")
            })
            .store(in: &cancellables)
    }

    
    func loadTrendingStocks() {
        apiService.fetchTrendingStocks()
            .sink(receiveCompletion: { completion in
                // Handle completion
            }, receiveValue: { [weak self] response in
                // Limiting to 5 items for each category
                self?.topGainers = Array(response.topGainers.prefix(2))
                self?.topLosers = Array(response.topLosers.prefix(2))
            })
            .store(in: &cancellables)
    }
}


