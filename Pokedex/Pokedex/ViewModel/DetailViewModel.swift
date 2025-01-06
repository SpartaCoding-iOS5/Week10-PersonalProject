//
//  DetailViewModel.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import Foundation
import RxSwift


class DetailViewModel {
    // MARK: - Properties
    
    /// 구독 해제를 위한 DisposeBag
    private let disposeBag = DisposeBag()
    /// 선택된 포켓몬 ID
    private let pokemonId: Int
    
    // MARK: - Subjects
    
    /// View가 구독할 Subjects
    let pokemonSubject = BehaviorSubject<PokemonDetail?>(value: nil)
    let loadingSubject = BehaviorSubject<Bool>(value: false)
    let errorSubject = PublishSubject<Error>()
    
    // MARK: - Initialization
    
    init(pokemonId: Int) {
        self.pokemonId = pokemonId
        fetchPokemonDetail()
    }
    
    // MARK: - Public Methods
    
    /// 포켓몬 상세 정보를 다시 불러옴
    func refresh() {
        fetchPokemonDetail()
    }
    
    /// 포켓몬 상세 정보를 불러오는 함수
    private func fetchPokemonDetail() {
        // 로딩 시작
        loadingSubject.onNext(true)
        
        // URL 생성
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)") else {
            errorSubject.onNext(NetworkError.invalidUrl)
            return
        }
        
        // 네트워크 요청
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (response: PokemonDetailResponse) in
                // 포켓몬 모델로 변환
                guard let imageUrl = URL(string: response.imageUrl) else {
                    self?.errorSubject.onNext(NetworkError.invalidUrl)
                    return
                }
                
                let mainType = PokemonType(rawValue: response.mainType)
                
                let detail = PokemonDetail(
                    id: response.id,
                    name: response.name,
                    imageURL: imageUrl,
                    height: response.heightInMeters,
                    weight: response.weightInKg,
                    mainType: mainType
                )
                
                // 데이터 전달
                self?.pokemonSubject.onNext(detail)
                self?.loadingSubject.onNext(false)
            }, onFailure: { [weak self] error in
                // 에러 전달
                self?.errorSubject.onNext(error)
                self?.loadingSubject.onNext(false)
            })
            .disposed(by: disposeBag)
    }
}

