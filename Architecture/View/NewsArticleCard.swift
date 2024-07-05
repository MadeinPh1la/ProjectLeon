//
//  NewsArticleCard.swift
//  Leon
//
//  Created by Kevin Downey on 3/21/24.
//

import SwiftUI

struct NewsArticleCard: View {
    let article: NewsArticle
    
    var body: some View {
        NavigationLink(destination: ArticleDetailView(article: article)) {
            
            VStack(alignment: .leading, spacing: 10) {
                
                if let imageURL = URL(string: article.banner_image), !article.banner_image.isEmpty {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: "photo")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(10)
                    .background(Color(.systemBackground)) // Adaptable background color
                    .shadow(radius: 5)
                    .padding(.horizontal) // Adds spacing between the card and the edges of the device
                    
                }
                
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityIdentifier("ArticleTitle-\(article.id)")
                
                Text(article.summary)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.horizontal)

        }
        .buttonStyle(PlainButtonStyle()) // Prevents the link from being styled like a button
    }
}
