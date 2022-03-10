//
//  MovieDetailResponse.swift
//  MyMovieMandiri
//
//  Created by Iskandar Herputra Wahidiyat on 10/03/22.
//

import Foundation

struct MovieDetailResponse: Codable {
    let title: String
    let backdrop_path: String
    let release_date: String
    let overview: String
}
