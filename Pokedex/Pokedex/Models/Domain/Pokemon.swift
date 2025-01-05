//
//  Pokemon.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import Foundation

/// 포켓몬의 기본 정보를 담는 모델
struct Pokemon {
    /// 포켓몬 도감 번호
    let id: Int
    /// 포켓몬 영문 이름
    let name: String
    /// 포켓몬 한글 이름
    let koreanName: String
    /// 포켓몬 이미지 URL
    let imageUrl: URL?
    
    /// 표시할 이름 (한글이 있으면 한글, 없으면 영문)
    var displayName: String {
        koreanName.isEmpty ? name.capitalized : koreanName
    }
}


