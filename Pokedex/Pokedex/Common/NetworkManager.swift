//
//  NetworkManager.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import Foundation
import RxSwift


/// 네트워크 요청 중 발생할 수 있는 에러 타입 정의
enum NetworkError: Error {
    /// 유효하지 않은 URL
    case invalidUrl
    /// 데이터 패치 실패 (서버 응답 오류 등)
    case dataFetchFail
    /// JSON 디코딩 실패
    case decodingFail
}

/// API 통신을 담당할 NetworkManger 클래스 (싱글톤 매니저 클래스)
class NetworkManager {
    /// 싱글톤 인스턴스(통로)
    static let shared = NetworkManager()
    /// 외부에서의 인스턴스 생성 방지
    private init() {}
    
    
    /// 제네릭 타입의 데이터를 패치하는 메서드
    /// - Parameter url: 요청할 API의 URL
    /// - Returns: 디코딩된 데이터를 포함한 Single 객체
    func fetch<T: Decodable>(url: URL) -> Single<T> {
        return Single.create{ observer in
            // URLSession 설정
            let session = URLSession(configuration: .default)
            
            // 데이터 테스크 생성 및 시작
            session.dataTask(with: URLRequest(url: url)) { data, response, error in
                // 에러 체크
                if let error = error {
                    observer(.failure(error))
                    return
                }
                
                // 응답 및 데이터 유효성 체크
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                // JSON 디코딩
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    observer(.success(decodedData))
                } catch {
                    observer(.failure(NetworkError.decodingFail))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}
