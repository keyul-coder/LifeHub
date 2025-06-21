//
//  Quote.swift
//  LifeHub
//
//  Created by keyul patel on 6/20/25.
//

import Foundation


struct Quote: Codable, Equatable {
    let text: String
    let author: String
    let category: String
    
    static func ==(lhs: Quote, rhs: Quote) -> Bool {
        return lhs.text == rhs.text && lhs.author == rhs.author
    }
}
