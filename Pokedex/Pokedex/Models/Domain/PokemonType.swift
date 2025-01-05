//
//  PokemonType.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import Foundation

/// 포켓몬의 타입을 정의하는 열거형
enum PokemonType: String {
    case normal
    case fire
    case water
    case electric
    case grass
    case ice
    case fighting
    case poison
    case ground
    case flying
    case psychic
    case bug
    case rock
    case ghost
    case dragon
    case dark
    case steel
    case fairy
    
    /// 타입의 한글 이름
    var localizedName: String {
        switch self {
        case .normal: return "노말"
        case .fire: return "불꽃"
        case .water: return "물"
        case .electric: return "전기"
        case .grass: return "풀"
        case .ice: return "얼음"
        case .fighting: return "격투"
        case .poison: return "독"
        case .ground: return "땅"
        case .flying: return "비행"
        case .psychic: return "에스퍼"
        case .bug: return "벌레"
        case .rock: return "바위"
        case .ghost: return "고스트"
        case .dragon: return "드래곤"
        case .dark: return "악"
        case .steel: return "강철"
        case .fairy: return "페어리"
        }
    }
    
    /// 타입의 대표 색상 (HEX 코드)
    var color: String {
        switch self {
        case .normal: return "#A8A878"
        case .fire: return "#F08030"
        case .water: return "#6890F0"
        case .electric: return "#F8D030"
        case .grass: return "#78C850"
        case .ice: return "#98D8D8"
        case .fighting: return "#C03028"
        case .poison: return "#A040A0"
        case .ground: return "#E0C068"
        case .flying: return "#A890F0"
        case .psychic: return "#F85888"
        case .bug: return "#A8B820"
        case .rock: return "#B8A038"
        case .ghost: return "#705898"
        case .dragon: return "#7038F8"
        case .dark: return "#705848"
        case .steel: return "#B8B8D0"
        case .fairy: return "#EE99AC"
        }
    }
}
