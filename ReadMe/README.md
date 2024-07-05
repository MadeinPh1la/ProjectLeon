# ProjectLeon
An iOS app for exclusive financial insight.

## Application Context

This project was named for an extraordinary town in Northern Spain. The app predicts next-day share price for 30 stocks in the Dow Jones Industrial Average using a machine learning regression model. It also parses balance statement, cash flow statement, income statement and more stock data from the Alphavantage API to calculate a the intrinsic value of a company and display the corresponding share price.  

### Key Features 

- Allow a search for any stock in the New York Stock Exchange or NASDAQ.
- Display standard quote of a company, including company profile and standard quote information.
- Calculate and display fair value estimate of share price (Discounted Cash Flow).
- Predict next-day share price for 30 stocks in the Dow Jones Industrial Average using a machine learning regression model.
- Allow investors to log in, sign up or sign out of the app using Google’s Firebase authentication
- Keep investors up to date with the latest news and trending stock, including the day’s biggest gainers and losers

### Model-View-ViewModel (MVVM) Architecture

MVVM makes my app's codebase more organized, testable, and maintainable.  The separation of concerns and encapsulation of responsibilities also makes it easier to add new features, update existing ones, and handle data fetching, calculations, and authentication.

#### Benefits

- Separation of Concerns: MVVM gives me a clean separation of concerns between the UI (View), data and business logic (ViewModel), and the model (data model). This supports my requirement of making the codebase more modular, testable, and maintainable.
- Reusable and Testable ViewModels: ViewModels encapsulate the presentation logic and data transformation, making them easier to test without involving the UI layer. This improves the testability and maintainability of your codebase.
- Encapsulated State Management: I use my FinancialViewModel to  manage the state of the UI, including user interactions, data fetching, and calculations. This centralized state management helps keep the UI logic organized and easier to reason about.
- Separation of Concerns for Network and Data Operations: In MVVM, network operations (like fetching data from the Alphavantage API and Firebase) and data manipulation (such as calculations for discounted cash flow) can be encapsulated in separate classes or services, promoting code reusability and modular design.

## Demo

### Application Features

 - Displays standard quote for user-inputted stocks
- Next-day share price prediction using Machine Learning regression model - Professional Discounted Cash Flow calculation for inherent value of company
- Latest stock market newsfeed with photos - List of Trending stocks (top gainers and losers)
- Account creation, sign in and sign out functionality

Learn more [here](https://madeinph1la.github.io)

