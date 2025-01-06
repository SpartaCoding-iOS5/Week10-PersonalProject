//
//  MainViewController.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa


class MainViewController: UIViewController {
    // MARK: - Properties
    /// 메인 화면의 데이터와 비즈니스 로직을 관리하는 ViewModel
    private let viewModel = MainViewModel()
    /// RxSwift 구독 해제를 위한 DisposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    /// 상단에 표시되는 포켓몬볼 이미지
    private let topImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "PokemonBall"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// 포켓몬 목록을 그리드 형태로 표시하는 컬렉션 뷰
    private lazy var collectionView: UICollectionView = {
        /// 레이아웃 설정
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1  // 줄 간격을 줄임
        layout.minimumInteritemSpacing = 1  // 아이템 간격을 줄임
        
        // 화면 너비에서 여백을 뺀 후 3등분
        let itemsPerRow: CGFloat = 3
        let padding: CGFloat = 1  // 전체 여백
        let availableWidth = UIScreen.main.bounds.width - (padding * 2) - (layout.minimumInteritemSpacing * (itemsPerRow - 1))
        let itemWidth = availableWidth / itemsPerRow
        
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)  // 정사각형 셀
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .darkRed  // 배경색을 하얀색으로
        collectionView.register(PokemonCell.self, forCellWithReuseIdentifier: PokemonCell.identifier)
        return collectionView
    }()
    
    /// 데이터 로딩 중임을 표시하는 인디케이터
    private let activityIndicator: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .mainRed
        
        [topImageView, collectionView, activityIndicator].forEach { view.addSubview ($0) }
        
        topImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topImageView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    /// ViewModel과의 데이터 바인딩 설정
    private func setupBindings() {
        // 포켓몬 목록 데이터 바인딩
        viewModel.pokemonListSubject
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: PokemonCell.identifier, cellType: PokemonCell.self)) {
                index, pokemon, cell in cell.configure(with: pokemon)
            }
            .disposed(by: disposeBag)
        
        // 로딩 상태 방인딩
        viewModel.loadingSubject
            .observe(on: MainScheduler.instance)
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 에러 처리
        viewModel.errorSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                let alertController = UIAlertController(title: "에러", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 셀 선택 시 상세화면으로 이동
        collectionView.rx.modelSelected(Pokemon.self)
            .subscribe(onNext: { [weak self] pokemon in
                let detailVC = DetailViewController(pokemonId: pokemon.id)
                self?.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 무한 스크롤 구현
        collectionView.rx.contentOffset
            .map { [weak self] offset in
                guard let self = self else { return false }
                let height = self.collectionView.contentSize.height
                let contentYOffset = offset.y
                let scrollViewHeight = self.collectionView.frame.size.height
                let distanceFromBottom = height - contentYOffset - scrollViewHeight
                return distanceFromBottom < 100
            }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self ] _ in
                self?.viewModel.fetchNextPage() // 다음 페이지 데이터 요청
            })
            .disposed(by: disposeBag)
    }
}

extension UIColor {
    static let mainRed = UIColor(red: 190/255, green: 30/255, blue: 40/255, alpha: 1.0)
    static let darkRed = UIColor(red: 120/255, green: 30/255, blue: 30/255, alpha: 1.0)
    static let cellBackground = UIColor(red: 245/255, green: 245/255, blue: 235/255, alpha: 1.0)
}
