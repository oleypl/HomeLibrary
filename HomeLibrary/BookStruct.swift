//
//  BookStruct.swift
//  HomeLibrary
//
//  Created by Michal Olejniczak on 27/07/2020.
//  Copyright © 2020 Michal Olejniczak. All rights reserved.
//

import Foundation

struct BooksStruct: Codable {
    var image: String?
    var title: String?
    var authors: [String]?
    var description: String?
    
        init(image: String, title: String, authors: [String], description: String){
            self.image = image
            self.title = title
            self.authors = authors
            self.description = description
        }
}



