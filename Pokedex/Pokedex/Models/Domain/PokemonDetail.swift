//
//  PokemonDetail.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import Foundation


/// 포켓몬의 상세 정보를 담는 모델
struct PokemonDetail {
    /// 포켓몬 도감 번호
    let id: Int
    /// 포켓몬 영문 이름
    let name: String
    /// 포켓몬 한글 이름
    var koreanName: String {
        return PokemonTranslator.getKoreanName(for: name)
    }
    /// 포켓몬 이미지 URL
    let imageURL: URL?
    /// 포켓몬 키(m)
    let height: Double
    /// 포켓몬 몸무게(Kg)
    let weight: Double
    /// 포켓몬 타입 목록
    let mainType: PokemonType?
    
    /// 표시할 이름 (한글이 있으면 한글, 없으면 영문)
    var displayName: String {
        return koreanName
    }
    
    /// 표시할 키
    var displayHeight: String {
        String(format: "%.1f m", height)
    }
    
    /// 표시할 몸무게
    var displayWeight: String {
        String(format: "%.1f Kg", weight)
    }
}
