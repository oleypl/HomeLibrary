//
//  Book.swift
//  HomeLibrary
//
//  Created by Michal Olejniczak on 25/07/2020.
//  Copyright © 2020 Michal Olejniczak. All rights reserved.
//

import Foundation
import UIKit


class Book: Equatable{
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.title == rhs.title && lhs.authors == rhs.authors
    }
    
    
    var image: String?
    var title: String?
    var authors: [String]?
    var description: String?
    
    var rating: Int?
    var isReaded: Bool?
    
    init(image: String, title: String, authors: [String], description: String){
        self.image = image
        self.title = title
        self.authors = authors
        self.description = description
    }
    
}
