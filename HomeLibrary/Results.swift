//
//  Results.swift
//  HomeLibrary
//
//  Created by Michal Olejniczak on 25/07/2020.
//  Copyright © 2020 Michal Olejniczak. All rights reserved.
//

import Foundation

struct Results: Codable {
    let items: [Item]?
}

struct Item: Codable {
    let volumeInfo: VolumeInfo?
}

struct VolumeInfo: Codable {
    let title: String?
    let subtitle: String?
    let authors: [String]?
    let imageLinks: ImageLinks?
    let language: String?
    let description: String?
}

struct ImageLinks: Codable {
    let smallThumbnail: String?
    let thumbnail: String?
}
