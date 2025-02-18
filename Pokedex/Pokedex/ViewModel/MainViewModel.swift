//
//  MainViewModel.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import Foundation
import RxSwift

/// 메인 화면의 포켓몬 목록을 관리하는 ViewModel
class MainViewModel {
    // MARK: - Properties
    
    /// 구독 해제를 위한 DisposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: - Subjects
    
    /// View가 구독할 Subjects
    let pokemonListSubject = BehaviorSubject<[Pokemon]>(value: [])
    let loadingSubject = BehaviorSubject<Bool>(value: false)
    let errorSubject = PublishSubject<Error>()
    
    // MARK: - Pagination Properties
    
    /// 페이지 정보
    private var currentPage = 0
    private let itemsPerPage = 20
    
    // MARK: - Initialization
    
    init() {
        fetchPokemonList()
    }
    
    // MARK: - Public Methods
    
    /// 포켓몬 리스트를 처음부터 다시 불러옴
    func refresh() {
        currentPage = 0
        fetchPokemonList()
    }
    
    
    /// 다음 페이지 포켓몬 리스트를 불러옴
    func fetchNextPage() {
        currentPage += 1
        fetchPokemonList()
    }
    
    // MARK: - Private Methods
    
    /// 포켓몬 리스트 데이터를 불러오는 함수
    private func fetchPokemonList() {
        print("포켓몬 리스트 불러오기 시작")
        /// 로딩 시작하기
        loadingSubject.onNext(true)
        
        /// URL 생성
        let offset = currentPage * itemsPerPage
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(itemsPerPage)") else {
            print("URL 생성 실패")
            errorSubject.onNext(NetworkError.invalidUrl)
            return
        }
        
        /// 네트워크 요청
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (response: PokemonListResponse) in
                // 포켓몬 모델로 변환
                print("API 응답 받음: \(response.results.count)개의 포켓몬")
                let pokemons = response.results.compactMap { item -> Pokemon? in
                    guard let id = item.id,
                          let imageUrlString = item.imageUrl,
                          let imageUrl = URL(string: imageUrlString) else {
                        print("포켓몬 데이터 변환 실패: \(item.name)")
                        return nil
                    }
                    
                    return Pokemon(
                        id: id,
                        name: item.name,
                        imageUrl: imageUrl
                    )
                }
                
                print("변환된 포켓몬 수: \(pokemons.count)")
                // 현재 리스트에 추가
                if let currentPokemons = try? self?.pokemonListSubject.value() {
                    self?.pokemonListSubject.onNext(currentPokemons + pokemons)
                } else {
                    self?.pokemonListSubject.onNext(pokemons)
                }
                
                // 로딩 완료
                self?.loadingSubject.onNext(false)
            }, onFailure: { [weak self] error in
                // 에러 전달
                print("에러 발생: \(error)")
                self?.errorSubject.onNext(error)
                self?.loadingSubject.onNext(false)
            })
            .disposed(by: disposeBag)
    }
}
