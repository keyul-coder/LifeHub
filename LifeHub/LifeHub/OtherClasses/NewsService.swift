//
//  NewsService.swift
//  LifeHub
//
//  Created by Smit Patel on 17/07/25.
//

import Foundation

enum NewsCategory: String, CaseIterable {
    case general = "general"
    case business = "business"
    case entertainment = "entertainment"
    case health = "health"
    case science = "science"
    case sports = "sports"
    case technology = "technology"
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .business: return "Business"
        case .entertainment: return "Entertainment"
        case .health: return "Health"
        case .science: return "Science"
        case .sports: return "Sports"
        case .technology: return "Technology"
        }
    }
    
    var iconName: String {
        switch self {
        case .general: return "newspaper"
        case .business: return "briefcase"
        case .entertainment: return "tv"
        case .health: return "heart"
        case .science: return "atom"
        case .sports: return "sportscourt"
        case .technology: return "laptopcomputer"
        }
    }
}

class NewsService {
    private let apiKey = "eee6aa0b57ec4496bc36f88d4d387c5f"
    private let baseURL = "https://newsapi.org/v2/top-headlines"

    func fetchTopHeadlines(completion: @escaping ([NewsArticle]?) -> Void) {
        guard let url = URL(string: "\(baseURL)?country=us&category=health&apiKey=\(apiKey)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                completion(decoded.articles)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchNewsByCategory(_ category: NewsCategory, completion: @escaping ([NewsArticle]?) -> Void) {
        guard let url = URL(string: "\(baseURL)?country=us&category=\(category.rawValue)&apiKey=\(apiKey)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                completion(decoded.articles)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchAllCategoriesNews(completion: @escaping ([NewsCategory: [NewsArticle]]) -> Void) {
        let group = DispatchGroup()
        var results: [NewsCategory: [NewsArticle]] = [:]
        
        for category in NewsCategory.allCases {
            group.enter()
            fetchNewsByCategory(category) { articles in
                if let articles = articles {
                    results[category] = articles
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }
}
