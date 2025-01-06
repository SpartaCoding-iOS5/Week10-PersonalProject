//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import UIKit
import SnapKit
import RxSwift

class PokemonCell: UICollectionViewCell {
    
    static let identifier = "PokemonCell"
    
    private let disposeBag = DisposeBag()
    
    // 컨테이너 뷰 추가
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cellBackground
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    // 포켓몬 이미지뷰
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    // 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 뷰 설정 메서드
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4) // 약간의 여백
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8) // 이미지 주변 여백
        }
    }
    
    // Cell 재사용 준비
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    // 포켓몬 데이터로 셀 구성하는 메서드
    func configure(with pokemon: Pokemon) {
        print("포켓몬 데이터 전달됨:", pokemon.displayName, pokemon.id)
        guard let imageUrl = pokemon.imageUrl else {
            print("포켓몬 이미지 URL이 없음:", pokemon.displayName)
            return
        }
        
        print("이미지 URL에서 로딩 시작:", imageUrl)
        
        // 이미지 로딩 전에 기존 이미지와 구독 초기화
        imageView.image = nil
        
        URLSession.shared.rx.data(request: URLRequest(url: imageUrl))
            .map { UIImage(data: $0) }
            .catch { error -> Observable<UIImage?> in
                print("이미지 로딩 에러 발생:", error)
                return .just(nil)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                if let image = image {
                    print("포켓몬 이미지 로드 완료:", pokemon.displayName)
                    self?.imageView.image = image
                }
            })
            .disposed(by: disposeBag)
    }
}
