//
//  DCFData.swift
//  Leon
//
//  Created by Kevin Downey on 2/18/24.
//

import Foundation

struct DCFData: Decodable {
    var freeCashFlow: Double
    var ebit: Double
    var taxRate: Double
    var capEx: Double
    var changeInWorkingCapital: Double
    var discountRate: Double
    var perpetualGrowthRate: Double
    var growthRate: Double
}

