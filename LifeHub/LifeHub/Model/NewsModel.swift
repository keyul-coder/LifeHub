//
//  NewsModel.swift
//  LifeHub
//
//  Created by Smit Patel on 17/07/25.
//

import Foundation

struct NewsResponse: Codable {
    let articles: [NewsArticle]
}

struct NewsArticle: Codable {
    let title: String
    let url: String
    let urlToImage: String?
    let description: String?
    let author: String?
    let publishedAt: String?
    let source: NewsSource?
}

struct NewsSource: Codable {
    let id: String?
    let name: String
}
