//
//  TechnicalIndicators.swift
//  Leon
//
//  Created by Kevin Downey on 4/12/24.
//

import Foundation

class TechnicalIndicators {
    // Calculate Simple Moving Average (SMA)
    static func calculateSMA(data: [Double], period: Int) -> [Double] {
        guard period <= data.count else { return [] }
        var result = [Double]()
        for i in 0..<(data.count - period + 1) {
            let slice = data[i..<(i + period)]
            let average = slice.reduce(0, +) / Double(period)
            result.append(average)
        }
        return result
    }

    // Calculate Exponential Moving Average (EMA)
    static func calculateEMA(data: [Double], period: Int) -> [Double] {
        guard data.count >= period else { return [] }
        var ema = [Double](repeating: 0, count: data.count)
        let sma = calculateSMA(data: data, period: period).first!
        ema[period-1] = sma
        
        let multiplier = 2.0 / (Double(period) + 1.0)
        for i in period..<data.count {
            ema[i] = (data[i] - ema[i-1]) * multiplier + ema[i-1]
        }
        return ema
    }

    // Calculate MACD
    static func calculateMACD(data: [Double]) -> [Double] {
        let ema12 = calculateEMA(data: data, period: 12)
        let ema26 = calculateEMA(data: data, period: 26)
        return zip(ema12, ema26).map { $0 - $1 }
    }

    // Calculate RSI
    static func calculateRSI(data: [Double], period: Int = 14) -> [Double] {
        guard data.count > period else { return [] }
        var rsi = [Double](repeating: 0, count: data.count)
        var gains = 0.0
        var losses = 0.0
        
        for i in 1..<period {
            let change = data[i] - data[i-1]
            if change > 0 {
                gains += change
            } else {
                losses -= change
            }
        }
        
        var avgGain = gains / Double(period)
        var avgLoss = losses / Double(period)
        
        if avgLoss == 0 {
            return Array(repeating: 100.0, count: data.count)
        }

        rsi[period-1] = 100 - (100 / (1 + (avgGain / avgLoss)))
        
        for i in period..<data.count {
            let change = data[i] - data[i-1]
            if change > 0 {
                gains = change
                losses = 0
            } else {
                gains = 0
                losses = -change
            }
            
            avgGain = ((avgGain * (Double(period) - 1)) + gains) / Double(period)
            avgLoss = ((avgLoss * (Double(period) - 1)) + losses) / Double(period)
            
            if avgLoss != 0 {
                rsi[i] = 100 - (100 / (1 + (avgGain / avgLoss)))
            } else {
                rsi[i] = 100
            }
        }
        
        return rsi
    }

    // Calculate Bollinger Bands
    static func calculateBollingerBands(data: [Double], period: Int = 20, multiplier: Double = 2.0) -> (upperBand: [Double], middleBand: [Double], lowerBand: [Double]) {
        let sma = calculateSMA(data: data, period: period)
        var upperBand = [Double](repeating: 0, count: data.count)
        var lowerBand = [Double](repeating: 0, count: data.count)
        
        for i in 0..<sma.count {
            let standardDeviation = standardDeviation(Array(data[i..<(i + period)]))
            upperBand[i + period - 1] = sma[i] + (standardDeviation * multiplier)
            lowerBand[i + period - 1] = sma[i] - (standardDeviation * multiplier)
        }
        
        return (upperBand, sma, lowerBand)
    }

    // Helper function to calculate standard deviation
    static func standardDeviation(_ arr: [Double]) -> Double {
        let length = Double(arr.count)
        let avg = arr.reduce(0, +) / length
        let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
}
