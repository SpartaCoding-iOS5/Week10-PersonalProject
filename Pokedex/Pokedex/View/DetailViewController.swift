//
//  DetailViewController.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa


class DetailViewController: UIViewController {
    // MARK: - Properties
    /// 포켓몬 상세 정보를 관리하는 ViewModel 인스턴스
    private let viewModel: DetailViewModel
    /// RxSwift 구독 해제를 위한 DisposeBag
    private let disposeBag = DisposeBag()
   
    // MARK: - UI Components
    /// 상세 정보를 감싸는 컨테이너 뷰
    private let contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkRed
        view.layer.cornerRadius = 20
        return view
    }()
    
    /// 포켓몬 이미지를 표시할 이미지뷰
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    /// 번호와 이름을 함께 표시할 스택뷰
    private let nameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    /// 번호 라벨
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    /// 이름 라벨
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
   
    /// 타입 라벨
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()
   
    /// 포켓몬 키 라벨
    private let heightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()
   
    /// 포켓몬 몸무게 라벨
    private let weightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    /// 로딩 뷰
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
   
    // MARK: - Initialization
    init(pokemonId: Int) {
        self.viewModel = DetailViewModel(pokemonId: pokemonId)
        super.init(nibName: nil, bundle: nil)
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
   
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .mainRed
 
        view.addSubview(contentContainerView)
       
        // nameStackView에 레이블들 추가
        nameStackView.addArrangedSubview(numberLabel)
        nameStackView.addArrangedSubview(nameLabel)
    
        [imageView, nameStackView, typeLabel, heightLabel, weightLabel, activityIndicator].forEach {
            contentContainerView.addSubview($0)
        }
       
        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(contentContainerView.snp.width).multipliedBy(1.1)
        }
       
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(contentContainerView.snp.width).multipliedBy(0.5)
        }
       
        nameStackView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    
        typeLabel.snp.makeConstraints {
            $0.top.equalTo(nameStackView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
       
        heightLabel.snp.makeConstraints {
            $0.top.equalTo(typeLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
       
        weightLabel.snp.makeConstraints {
            $0.top.equalTo(heightLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
       
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    /// ViewModel과의 데이터 바인딩 설정
    private func setupBindings() {
        // 포켓몬 데이터 구독 및 UI 업데이트
        viewModel.pokemonSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] pokemon in
                guard let pokemon = pokemon else { return }
                self?.updateUI(with: pokemon)
            })
            .disposed(by: disposeBag)
       
        // 로딩 상태 구독 및 인디케이터 처리
        viewModel.loadingSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.contentContainerView.alpha = 0.5
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.contentContainerView.alpha = 1.0
                }
            })
            .disposed(by: disposeBag)
       
        // 에러 처리 및 알림
        viewModel.errorSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                let alert = UIAlertController(title: "에러",
                                            message: error.localizedDescription,
                                            preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
   
    /// 포켓몬 데이터로 UI 업데이트
    private func updateUI(with pokemon: PokemonDetail) {
        // 기본 정보 업데이트
        numberLabel.text = "No.\(pokemon.id)"
        nameLabel.text = pokemon.displayName
        typeLabel.text = "타입: \(pokemon.mainType?.localizedName ?? "")"
        heightLabel.text = "키: \(pokemon.displayHeight)"
        weightLabel.text = "몸무게: \(pokemon.displayWeight)"
       
        // 이미지 비동기 로딩
        if let imageURL = pokemon.imageURL {
            URLSession.shared.rx.data(request: URLRequest(url: imageURL))
                .map { UIImage(data: $0) }
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] image in
                    self?.imageView.image = image
                })
                .disposed(by: disposeBag)
        }
    }
}
