//
//  MovieListResponse.swift
//  MyMovieMandiri
//
//  Created by Iskandar Herputra Wahidiyat on 10/03/22.
//

import Foundation

struct MovieListResponse: Codable {
    let results: [MovieListResponseDetail]
}
