//
//  LeonUITests.swift
//  LeonUITests
//
//  Created by Kevin Downey on 1/18/24.
//

import XCTest
import FirebaseAuth
@testable import Leon

final class LeonUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Add teardown code if needed.
    }
    
    
    // Test fetching Stock quote data
    func testFetchingStockQuoteDisplaysDetails() {
        let app = XCUIApplication()
        app.launch()
        
        let symbolTextField = app.textFields["symbolTextField"]
        XCTAssertTrue(symbolTextField.exists)
        symbolTextField.tap()
        symbolTextField.typeText("AAPL")
        
        let fetchButton = app.buttons["fetchButton"]
        XCTAssertTrue(fetchButton.exists)
        fetchButton.tap()
        
        let stockSymbolLabel = app.staticTexts["stockSymbolLabel"]
        XCTAssertTrue(stockSymbolLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(stockSymbolLabel.label, "AAPL")
    }
    
    // Test launch performace
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testStockListDisplaysCorrectData() {
        let app = XCUIApplication()
        XCTAssertTrue(app.textFields["symbolTextField"].waitForExistence(timeout: 10), "Symbol text field should be visible on MainAppView")
        XCTAssertTrue(app.buttons["fetchButton"].waitForExistence(timeout: 5), "Fetch button should be visible on MainAppView")
        
        let topGainersLink = app.buttons["viewAllTopGainers"]
        XCTAssertTrue(topGainersLink.waitForExistence(timeout: 10), "Top Gainers Link should exist")
        topGainersLink.tap()
        
        sleep(5) // Give some time for the view to load potentially slow data
        
        let stocksListView = app.scrollViews["stocksListView"]
        XCTAssertTrue(stocksListView.waitForExistence(timeout: 10), "StocksListView should be visible after tapping 'View All Top Gainers'")
        
        print("Accessibility Hierarchy after tapping 'View All Top Gainers': \(app.debugDescription)")
    }
    
    func testNewsArticleCardNavigation() {
        let app = XCUIApplication()
        
        // Identify the tab bar item for NewsFeedView
        let newsFeedTabBarItem = app.tabBars.buttons["NewsTab"]
        
        // Tap on the tab bar item to navigate to NewsFeedView
        newsFeedTabBarItem.tap()
        
        // Assert that the NewsFeedView is visible
        let newsFeedView = app.otherElements["NewsFeedView"]
        XCTAssertTrue(newsFeedView.waitForExistence(timeout: 2))
        
        // Find the first NewsArticleCard within the NewsFeedView
        let articleCard = newsFeedView.buttons["NewsFeedView"].firstMatch
        
        // Assert that the card is visible
        XCTAssertTrue(articleCard.exists)
        
        // Tap on the card to navigate to ArticleDetailView
        articleCard.tap()
        
        // Add a short delay to allow time for navigation
        sleep(1)
        
        // Assert that the navigation occurred and the ArticleDetailView is visible
        let detailView = app.navigationBars["Article"]
        XCTAssertTrue(detailView.exists)
    }
    
    func testTabNavigation() {
        let app = XCUIApplication()

        // Access the tabs using the accessibility identifiers
        let financialTab = app.buttons["FinancialTab"]
        let newsTab = app.buttons["NewsTab"]

        // Test if the Financial tab is loaded correctly
        financialTab.tap()
        XCTAssertTrue(financialTab.isSelected, "The Financial tab should be selected")

        // Test if the News tab can be selected and is loaded correctly
        newsTab.tap()
        XCTAssertTrue(newsTab.isSelected, "The News tab should be selected")
    }
    
    func testSearchInputNavigationAndDataDisplayInDetailView() {
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Financial tab
        let financialTab = app.buttons["FinancialTab"]
        financialTab.tap()

        // Locate and interact with the search field
        let searchField = app.textFields["symbolEntryField"]
        XCTAssertTrue(searchField.exists, "Search field should be present on the Financial tab")
        
        // Enter 'AAPL' into the search field and submit
        searchField.tap()
        searchField.typeText("AAPL\n")
        
        // Tap the fetch button to trigger data loading
        let fetchButton = app.buttons["fetchButton"]
        fetchButton.tap()

        // Wait for the detail view to appear
        let detailView = app.otherElements["FinancialDetailView"]
        let exists = NSPredicate(format: "exists == true")

        // Correct the element used in expectation
        expectation(for: exists, evaluatedWith: detailView, handler: nil)
        waitForExpectations(timeout: 20, handler: nil)  // Increased timeout
        XCTAssertTrue(detailView.exists, "FinancialDetailView should be visible after submitting the search")

        // Verify that the correct data is displayed in FinancialDetailView
        let detailContent = app.staticTexts["stockSymbolLabel"]
        XCTAssertTrue(detailContent.exists, "Financial content specific to 'AAPL' should be visible in FinancialDetailView")
    }
    
    func testConsistentUseOfSymbol() {
        let app = XCUIApplication()

        // Start by selecting the News tab, which directly uses the 'AAPL' symbol
        let newsTab = app.buttons["NewsTab"]
        newsTab.tap()

        // Check if the News content related to 'AAPL' is displayed
        let newsContentForSymbol = app.staticTexts["NewsContentAAPL"]
        XCTAssertTrue(newsContentForSymbol.exists, "News content specific to the symbol 'AAPL' should be visible in the News tab")

        // Navigate to another tab where the symbol might influence displayed content
        let financialTab = app.buttons["FinancialTab"]
        financialTab.tap()

        // Check if the Financial view correctly reflects the 'AAPL' symbol
        let financialContentForSymbol = app.staticTexts["FinancialContentAAPL"]
        XCTAssertTrue(financialContentForSymbol.exists, "Financial content specific to the symbol 'AAPL' should be visible in the Financial tab")
    }



}
