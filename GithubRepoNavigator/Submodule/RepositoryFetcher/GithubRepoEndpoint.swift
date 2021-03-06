//
//  GithubRepoProvider.swift
//  GithubRepoNavigator
//
//  Created by Won Cheul Seok on 2017. 12. 12..
//  Copyright © 2017년 Evan Seok. All rights reserved.
//

import Foundation
import Moya

struct GithubRepoEndpoint: TargetType {
    var headers: [String : String]?
    
    var baseURL: URL {
        return URL(string:"https://api.github.com")!
    }
    
    var path: String {
        return "/repositories"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return """
        [
            {
                "id": 1296269,
                "owner": {
                    "login": "octocat",
                    "id": 1,
                    "avatar_url": "https://github.com/images/error/octocat_happy.gif",
                    "gravatar_id": "",
                    "url": "https://api.github.com/users/octocat",
                    "html_url": "https://github.com/octocat",
                    "followers_url": "https://api.github.com/users/octocat/followers",
                    "following_url": "https://api.github.com/users/octocat/following{/other_user}",
                    "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
                    "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
                    "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
                    "organizations_url": "https://api.github.com/users/octocat/orgs",
                    "repos_url": "https://api.github.com/users/octocat/repos",
                    "events_url": "https://api.github.com/users/octocat/events{/privacy}",
                    "received_events_url": "https://api.github.com/users/octocat/received_events",
                    "type": "User",
                    "site_admin": false
                },
                "name": "Hello-World",
                "full_name": "octocat/Hello-World",
                "description": "This your first repo!",
                "private": false,
                "fork": false,
                "url": "https://api.github.com/repos/octocat/Hello-World",
                "html_url": "https://github.com/octocat/Hello-World"
            }
        ]
        """.data(using: .utf8)!
    }
    
    var task: Moya.Task {
        return .requestPlain
    }
}
