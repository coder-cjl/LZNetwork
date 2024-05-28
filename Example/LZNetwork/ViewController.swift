//
//  ViewController.swift
//  LZNetwork
//
//  Created by coder-cjl on 05/22/2024.
//  Copyright (c) 2024 coder-cjl. All rights reserved.
//

import UIKit
import LZNetwork
import Moya
import _Concurrency

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func testLoadConfig() {
        LZEnv.default.loadConfig("xxx", loadCache: true)
    }
    
    func testLoginAwaitResult() {
        _Concurrency.Task {
            let result = await LZRequest<User>().request(TestTargetApi.login("123", "123"))
            switch result {
            case .success(let t):
                print(t?.name ?? "")
            case .failure(let error):
                print(error.errorDescription ?? "")
            }
        }
    }
    
    func testLoginAwaitOnlySuccess() {
        _Concurrency.Task {
            if let user = await LZRequest<User>().requestOnlySuccess(TestTargetApi.login("123", "123")) {
                print(user.name ?? "")
            } else {
                print("Faliure")
            }
        }
    }
    
    func testSmsHandleResult() {
        LZRequest().request(target: TestTargetApi.sms("123"), type: User.self) { result in
            switch result {
            case .success(let user):
                print(user?.name ?? "")
            case .failure(let error):
                print(error.errorDescription ?? "")
            }
        }
    }
    
    func testSmsResultOnlySuccess() {
        LZRequest().requestOnlySuccess(TestTargetApi.sms("123"), type: User.self) { value in
            if let user = value {
                print(user.name ?? "")
            } else {
                print("Faliure")
            }
        }
    }
    
    func testList() {

    }
    
    func testURLCache() {
        _Concurrency.Task {
            let result = await LZRequest<[List]>(plugins:[LZGetwayPlugin(), LZCachePlugin()]).request(TestTargetApi.list)
            switch result {
            case .success(let list):
                print(list?.count ?? "0")
            case .failure(let error):
                print(error.errorDescription ?? "")
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

struct User: Decodable {
    let name: String?
    let age: Int?
    let accessToken: String?
}

struct Item: Decodable {
    let name: String?
    let id: Int?
}

struct List: Decodable {
    let group: String?
    let name: String?
    let items: [Item]?
}

enum TestTargetApi {
    case login(String, String)
    case sms(String)
    case list
}

extension TestTargetApi: LZTargetType {
    
    var path: String {
        switch self {
        case .login(_, _):
            return "v1/login"
        case .sms(_):
            return "v1/sms"
        case .list:
            return "v1/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .sms:
            return .post
        case .list:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .login(let phone, let password):
            let params = ["phoneNo": phone, "password": password]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .sms(let phone):
            let params = ["phoneNo": phone]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .list:
            return .requestPlain
        }
    }
}


extension LZTargetType {
    var baseURL: URL {
        if let urlStr = LZEnv.default.currentURLConfig?["api_url"] as? String,
           let url = URL(string: urlStr) {
            return url
        }
        return URL.init(string: "")!
    }

    var task: Moya.Task {
        .requestPlain
    }

    var headers: [String : String]? {
        var h = [String: String]()
        h["version"] = "0.0.1"
        h["platform"] = "ios"
        h["Content-Type"] = "application/json"
//        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
//            h["Authorization"] = "Bearer \(accessToken)"
//        }
        return h
    }
}
