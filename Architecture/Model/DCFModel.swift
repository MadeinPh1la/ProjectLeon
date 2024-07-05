//
//  DCFModel.swift
//  Leon
//
//  Created by Kevin Downey on 3/7/24.
//

import Foundation

class DCFModel {
    var highGrowthRate: Double = 0.15
    var transitionGrowthRate: Double = 0.10
    var perpetualGrowthRate: Double = 0.02
    var discountRate: Double = 0.10

    // Include company's cash flow statement, balance sheet and income statement data in the calculation
    func calculateDCF(freeCashFlow: Double, netIncome: Double, longTermDebt: Double, cashAndEquivalents: Double) -> Double {
        let initialFCF = freeCashFlow
        let highGrowthFCF = calculateStageFCF(initialFCF: initialFCF, growthRate: highGrowthRate, years: 5)
        let transitionFCF = calculateTransitionStageFCF(lastHighGrowthFCF: highGrowthFCF.last!, startGrowthRate: transitionGrowthRate, endGrowthRate: perpetualGrowthRate, years: 5)
        let terminalValue = calculateTerminalValue(lastFCF: transitionFCF.last!, growthRate: perpetualGrowthRate)
        
        let pvHighGrowthFCF = presentValueOfCashFlows(cashFlows: highGrowthFCF)
        let pvTransitionFCF = presentValueOfCashFlows(cashFlows: transitionFCF)
        let pvTerminalValue = terminalValue / pow(1 + discountRate, 10)
    
        let totalPV = pvHighGrowthFCF + pvTransitionFCF + pvTerminalValue
        let netDebt = longTermDebt - cashAndEquivalents
        let enterpriseValue = totalPV - netDebt 
        
        return enterpriseValue
    }

        
        private func calculateStageFCF(initialFCF: Double, growthRate: Double, years: Int) -> [Double] {
            var cashFlows: [Double] = []
            var currentFCF = initialFCF
            for _ in 1...years {
                currentFCF *= (1 + growthRate)
                cashFlows.append(currentFCF)
            }
            return cashFlows
        }
        
        private func calculateTransitionStageFCF(lastHighGrowthFCF: Double, startGrowthRate: Double, endGrowthRate: Double, years: Int) -> [Double] {
            let decrement = (startGrowthRate - endGrowthRate) / Double(years - 1)
            var cashFlows: [Double] = []
            var currentGrowthRate = startGrowthRate
            var currentFCF = lastHighGrowthFCF
            for _ in 1...years {
                currentFCF *= (1 + currentGrowthRate)
                cashFlows.append(currentFCF)
                currentGrowthRate -= decrement
            }
            return cashFlows
        }
        
        private func calculateTerminalValue(lastFCF: Double, growthRate: Double) -> Double {
            return lastFCF * (1 + growthRate) / (discountRate - growthRate)
        }
        
        private func presentValueOfCashFlows(cashFlows: [Double]) -> Double {
            var presentValue: Double = 0
            for (index, cashFlow) in cashFlows.enumerated() {
                presentValue += cashFlow / pow(1 + discountRate, Double(index + 1))
            }
            return presentValue
        }
    }
