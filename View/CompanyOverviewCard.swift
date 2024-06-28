//
//  CompanyOverviewCard.swift
//  Leon
//
//  Created by Kevin Downey on 2/18/24.
//

import SwiftUI

struct CompanyOverviewCard: View {
    var overview: CompanyOverview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(overview.name)
                .font(.headline)
            Text(overview.description)
                .font(.body)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

