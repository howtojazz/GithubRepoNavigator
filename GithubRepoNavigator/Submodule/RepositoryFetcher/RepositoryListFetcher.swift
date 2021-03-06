//
//  RepositoryListFetcher.swift
//  GithubRepoNavigator
//
//  Created by Won Cheul Seok on 2017. 12. 10..
//  Copyright © 2017년 Evan Seok. All rights reserved.
//

import UIKit
import RxSwift



enum RepositoryListFetcherError:Error {
    case noResponseReturnedFromServer
    case serverResponseError(code:Int)
    case noDataReturnedFromServer
    case unexpectedRootFormatOfJson(json:Any)
    case noOwnerEntryFounded(json:[String:Any])
    case noOwnerNameEntryFounded(json:[String:Any])
    case invaildAvatarURLString(json:[String:Any])
}

struct RepositoryInfo : Equatable, Hashable {
    
    var hashValue: Int {
        return owner.hashValue
    }
    
    static func ==(lhs: RepositoryInfo, rhs: RepositoryInfo) -> Bool {
        return lhs.owner == rhs.owner
    }
    
    var avatar:URL?
    var owner:String!
    
    init(json:[String:Any]!) throws {
        guard let ownerEntry = json["owner"] as? [String:Any] else {
            throw RepositoryListFetcherError.noOwnerEntryFounded(json: json)
        }
        guard let nameEntry = ownerEntry["login"] as? String else {
            throw RepositoryListFetcherError.noOwnerNameEntryFounded(json: json)
        }
        owner = nameEntry
        if let avatarUrlString = ownerEntry["avatar_url"] as? String {
            guard let avatarURL = URL(string:avatarUrlString) else {
                throw RepositoryListFetcherError.invaildAvatarURLString(json: json)
            }
            avatar = avatarURL
        }
    }
}

final class RepositoryListFetcher {
    
    static let shared = RepositoryListFetcher()
    
    private var since:Int = 0
    
    func nextPageObserver(reset:Bool) -> Observable<[RepositoryInfo]> {
        if true == reset {
            self.since = 0
        }
        
        return Observable<[RepositoryInfo]>.create{ (observer) -> Disposable in
            
            let url = URL(string: "https://api.github.com/repositories?since=\(self.since)")!
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard nil == error else {
                    observer.onError(error!)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    observer.onError(RepositoryListFetcherError.noResponseReturnedFromServer)
                    return
                }
                guard 200 == response.statusCode else {
                    observer.onError(RepositoryListFetcherError.serverResponseError(code: response.statusCode))
                    return
                }
                guard let data = data else {
                    observer.onError(RepositoryListFetcherError.noDataReturnedFromServer)
                    return
                }
                
                var repositoryInfos = [RepositoryInfo]()
                
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] else {
                        observer.onError(RepositoryListFetcherError.unexpectedRootFormatOfJson(json: try JSONSerialization.jsonObject(with: data, options: [])))
                        return
                    }
                    
                    for repositoryDict in json {
                        repositoryInfos.append(try RepositoryInfo(json:repositoryDict))
                    }
                    
                    // store next page id
                    self.since = json.last!["id"] as? Int ?? 0
                }catch {
                    observer.onError(error)
                    return
                }
                var duplicatedInfos = Set<RepositoryInfo>()
                let distinctInfos = repositoryInfos.flatMap { (repoInfo) -> RepositoryInfo? in
                    guard !duplicatedInfos.contains(repoInfo) else {
                        return nil
                    }
                    duplicatedInfos.insert(repoInfo)
                    return repoInfo
                }
                observer.onNext(distinctInfos)
            }
            task.resume()
            
            return Disposables.create() {
                task.cancel()
            }
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
    }
}
