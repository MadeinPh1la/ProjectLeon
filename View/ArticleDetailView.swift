//
//  ArticleDetailView.swift
//  Leon
//
//  Created by Kevin Downey on 3/21/24.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: NewsArticle

    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(article.title)
                    .font(.title)
                    .padding(.bottom)

                // Display image
                if let imageURL = URL(string: article.banner_image), !article.banner_image.isEmpty {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                }

                Text(article.summary)
                    .font(.body)
                    .padding(.bottom)

                // Provide a link to the full article
                if let url = URL(string: article.url) {
                    Link("Read Full Article", destination: url)
                        .font(.headline)
                }
            }
            .padding()
            .accessibilityIdentifier("ArticleDetailView")
            .onAppear {
                        print("Displaying article: \(article.title)")
                        // Add a breakpoint or sleep statement here
                    }
        }
        .navigationBarTitle(Text("Article"), displayMode: .inline)
    }
}
