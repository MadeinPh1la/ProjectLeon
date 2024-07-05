import yfinance as yf
import pandas as pd
from datetime import datetime, timedelta
import talib

# Define the stock symbols for the Dow Jones Industrial Average
dow_symbols = [
'MMM', 'AOS', 'ABT', 'ABBV', 'ACN', 'ADBE', 'AMD', 'AES', 'AFL', 'A', 'APD', 'ABNB', 'AKAM', 'ALB', 'ARE', 'ALGN', 'ALLE', 'LNT', 'ALL', 'GOOGL', 'GOOG', 'MO', 'AMZN', 'AMCR', 'AEE', 'AAL', 'AEP', 'AXP', 'AIG', 'AMT', 'AWK', 'AMP', 'AME', 'AMGN', 'APH', 'ADI', 'ANSS', 'AON', 'APA', 'AAPL', 'AMAT', 'APTV', 'ACGL', 'ADM', 'ANET', 'AJG', 'AIZ', 'T', 'ATO', 'ADSK', 'ADP', 'AZO', 'AVB', 'AVY', 'AXON', 'BKR', 'BALL', 'BAC', 'BK', 'BBWI', 'BAX', 'BDX', 'BRK-B', 'BBY', 'BIO', 'TECH', 'BIIB', 'BLK', 'BX', 'BA', 'BKNG', 'BWA', 'BXP', 'BSX', 'BMY', 'AVGO', 'BR', 'BRO', 'BF-B', 'BLDR', 'BG', 'CDNS', 'CZR', 'CPT', 'CPB', 'COF', 'CAH', 'KMX', 'CCL', 'CARR', 'CTLT', 'CAT', 'CBOE', 'CBRE', 'CDW', 'CE', 'COR', 'CNC', 'CNP', 'CF', 'CHRW', 'CRL', 'SCHW', 'CHTR', 'CVX', 'CMG', 'CB', 'CHD', 'CI', 'CINF', 'CTAS', 'CSCO', 'C', 'CFG', 'CLX', 'CME', 'CMS', 'KO', 'CTSH', 'CL', 'CMCSA', 'CMA', 'CAG', 'COP', 'ED', 'STZ', 'CEG', 'COO', 'CPRT', 'GLW', 'CPAY', 'CTVA', 'CSGP', 'COST', 'CTRA', 'CCI', 'CSX', 'CMI', 'CVS', 'DHR', 'DRI', 'DVA', 'DAY', 'DECK', 'DE', 'DAL', 'DVN', 'DXCM', 'FANG', 'DLR', 'DFS', 'DG', 'DLTR', 'D', 'DPZ', 'DOV', 'DOW', 'DHI', 'DTE', 'DUK', 'DD', 'EMN', 'ETN', 'EBAY', 'ECL', 'EIX', 'EW', 'EA', 'ELV', 'LLY', 'EMR', 'ENPH', 'ETR', 'EOG', 'EPAM', 'EQT', 'EFX', 'EQIX', 'EQR', 'ESS', 'EL', 'ETSY', 'EG', 'EVRG', 'ES', 'EXC', 'EXPE', 'EXPD', 'EXR', 'XOM', 'FFIV', 'FDS', 'FICO', 'FAST', 'FRT', 'FDX', 'FIS', 'FITB', 'FSLR', 'FE', 'FI', 'FMC', 'F', 'FTNT', 'FTV', 'FOXA', 'FOX', 'BEN', 'FCX', 'GRMN', 'IT', 'GE', 'GEHC', 'GEV', 'GEN', 'GNRC', 'GD', 'GIS', 'GM', 'GPC', 'GILD', 'GPN', 'GL', 'GS', 'HAL', 'HIG', 'HAS', 'HCA', 'DOC', 'HSIC', 'HSY', 'HES', 'HPE', 'HLT', 'HOLX', 'HD', 'HON', 'HRL', 'HST', 'HWM', 'HPQ', 'HUBB', 'HUM', 'HBAN', 'HII', 'IBM', 'IEX', 'IDXX', 'ITW', 'ILMN', 'INCY', 'IR', 'PODD', 'INTC', 'ICE', 'IFF', 'IP', 'IPG', 'INTU', 'ISRG', 'IVZ', 'INVH', 'IQV', 'IRM', 'JBHT', 'JBL', 'JKHY', 'J', 'JNJ', 'JCI', 'JPM', 'JNPR', 'K', 'KVUE', 'KDP', 'KEY', 'KEYS', 'KMB', 'KIM', 'KMI', 'KLAC', 'KHC', 'KR', 'LHX', 'LH', 'LRCX', 'LW', 'LVS', 'LDOS', 'LEN', 'LIN', 'LYV', 'LKQ', 'LMT', 'L', 'LOW', 'LULU', 'LYB', 'MTB', 'MRO', 'MPC', 'MKTX', 'MAR', 'MMC', 'MLM', 'MAS', 'MA', 'MTCH', 'MKC', 'MCD', 'MCK', 'MDT', 'MRK', 'META', 'MET', 'MTD', 'MGM', 'MCHP', 'MU', 'MSFT', 'MAA', 'MRNA', 'MHK', 'MOH', 'TAP', 'MDLZ', 'MPWR', 'MNST', 'MCO', 'MS', 'MOS', 'MSI', 'MSCI', 'NDAQ', 'NTAP', 'NFLX', 'NEM', 'NWSA', 'NWS', 'NEE', 'NKE', 'NI', 'NDSN', 'NSC', 'NTRS', 'NOC', 'NCLH', 'NRG', 'NUE', 'NVDA', 'NVR', 'NXPI', 'ORLY', 'OXY', 'ODFL', 'OMC', 'ON', 'OKE', 'ORCL', 'OTIS', 'PCAR', 'PKG', 'PANW', 'PARA', 'PH', 'PAYX', 'PAYC', 'PYPL', 'PNR', 'PEP', 'PFE', 'PCG', 'PM', 'PSX', 'PNW', 'PXD', 'PNC', 'POOL', 'PPG', 'PPL', 'PFG', 'PG', 'PGR', 'PLD', 'PRU', 'PEG', 'PTC', 'PSA', 'PHM', 'QRVO', 'PWR', 'QCOM', 'DGX', 'RL', 'RJF', 'RTX', 'O', 'REG', 'REGN', 'RF', 'RSG', 'RMD', 'RVTY', 'RHI', 'ROK', 'ROL', 'ROP', 'ROST', 'RCL', 'SPGI', 'CRM', 'SBAC', 'SLB', 'STX', 'SRE', 'NOW', 'SHW', 'SPG', 'SWKS', 'SJM', 'SNA', 'SOLV', 'SO', 'LUV', 'SWK', 'SBUX', 'STT', 'STLD', 'STE', 'SYK', 'SMCI', 'SYF', 'SNPS', 'SYY', 'TMUS', 'TROW', 'TTWO', 'TPR', 'TRGP', 'TGT', 'TEL', 'TDY', 'TFX', 'TER', 'TSLA', 'TXN', 'TXT', 'TMO', 'TJX', 'TSCO', 'TT', 'TDG', 'TRV', 'TRMB', 'TFC', 'TYL', 'TSN', 'USB', 'UBER', 'UDR', 'ULTA', 'UNP', 'UAL', 'UPS', 'URI', 'UNH', 'UHS', 'VLO', 'VTR', 'VLTO', 'VRSN', 'VRSK', 'VZ', 'VRTX', 'VTRS', 'VICI', 'V', 'VMC', 'WRB', 'WAB', 'WBA', 'WMT', 'DIS', 'WBD', 'WM', 'WAT', 'WEC', 'WFC', 'WELL', 'WST', 'WDC', 'WRK', 'WY', 'WMB', 'WTW', 'GWW', 'WYNN', 'XEL', 'XYL', 'YUM', 'ZBRA', 'ZBH', 'ZTS'
]

# Set the start and end dates for training data (past 15 years up until one year ago)
end_date_train = (datetime.now() - timedelta(days=365)).strftime('%Y-%m-%d')
start_date_train = (datetime.now() - timedelta(days=15 * 365)).strftime('%Y-%m-%d')

# Set the start and end dates for testing data (past year)
end_date_test = datetime.now().strftime('%Y-%m-%d')
start_date_test = (datetime.now() - timedelta(days=365)).strftime('%Y-%m-%d')

# Create empty lists to store the training and testing data
train_data = []
test_data = []

# Download historical prices for each stock
for symbol in dow_symbols:
    ticker = yf.Ticker(symbol)
    hist_train = ticker.history(start=start_date_train, end=end_date_train)
    hist_test = ticker.history(start=start_date_test, end=end_date_test)

    # Extract the relevant columns for training data
    hist_train_data = hist_train.reset_index()
    hist_train_data = hist_train_data[['Date', 'Close', 'Volume']]
    hist_train_data['Stock'] = symbol

    # Calculate technical indicators and lagged values for training data

    # Calculate moving averages
    hist_train_data['MA_20'] = hist_train_data['Close'].rolling(window=20).mean()
    hist_train_data['MA_50'] = hist_train_data['Close'].rolling(window=50).mean()
    hist_train_data['MA_200'] = hist_train_data['Close'].rolling(window=200).mean()

    # Calculate technical indicators using TA-Lib
    hist_train_data['RSI'] = talib.RSI(hist_train_data['Close'])
    hist_train_data['MACD'], _, _ = talib.MACD(hist_train_data['Close'])
    upper, middle, lower = talib.BBANDS(hist_train_data['Close'])
    hist_train_data['BB_Upper'] = upper
    hist_train_data['BB_Middle'] = middle
    hist_train_data['BB_Lower'] = lower

    # Calculate lagged values
    hist_train_data['Prev_Close_1'] = hist_train_data['Close'].shift(1)
    hist_train_data['Prev_Close_7'] = hist_train_data['Close'].shift(7)
    hist_train_data['Prev_Close_30'] = hist_train_data['Close'].shift(30)

    train_data.append(hist_train_data)

    # Extract the relevant columns for testing data
    hist_test_data = hist_test.reset_index()
    hist_test_data = hist_test_data[['Date', 'Close', 'Volume']]
    hist_test_data['Stock'] = symbol

    # Calculate technical indicators and lagged values for testing data
    # Calculate moving averages
    hist_test_data['MA_20'] = hist_test_data['Close'].rolling(window=20).mean()
    hist_test_data['MA_50'] = hist_test_data['Close'].rolling(window=50).mean()
    hist_test_data['MA_200'] = hist_test_data['Close'].rolling(window=200).mean()

    # Calculate technical indicators using TA-Lib
    hist_test_data['RSI'] = talib.RSI(hist_test_data['Close'])
    hist_test_data['MACD'], _, _ = talib.MACD(hist_test_data['Close'])
    upper, middle, lower = talib.BBANDS(hist_test_data['Close'])
    hist_test_data['BB_Upper'] = upper
    hist_test_data['BB_Middle'] = middle
    hist_test_data['BB_Lower'] = lower

    # Calculate lagged values
    hist_test_data['Prev_Close_1'] = hist_test_data['Close'].shift(1)
    hist_test_data['Prev_Close_7'] = hist_test_data['Close'].shift(7)
    hist_test_data['Prev_Close_30'] = hist_test_data['Close'].shift(30)

    test_data.append(hist_test_data)

# Combine the training and testing data into separate DataFrames
df_train = pd.concat(train_data)
df_test = pd.concat(test_data)

# Add the target variable (future closing price) to both DataFrames
future_days = 1  # Adjust the number of days as needed
df_train['Target'] = df_train['Close'].shift(-future_days)
df_test['Target'] = df_test['Close'].shift(-future_days)

# Remove rows with missing values
df_train = df_train.dropna()
df_test = df_test.dropna()

# Save the training and testing data to separate CSV files
df_train.to_csv('djia_enhanced_data_train.csv', index=False)
df_test.to_csv('djia_enhanced_data_test.csv', index=False)

# Split the testing data into validation and testing datasets
validation_ratio = 0.5  # Adjust the ratio as needed
validation_size = int(len(df_test) * validation_ratio)

df_validation = df_test[:validation_size]
df_test = df_test[validation_size:]

# Save the validation dataset to a separate CSV file
df_validation.to_csv('djia_enhanced_data_validation.csv', index=False)

print("Enhanced training, validation, and testing data for DJIA stocks have been saved.")