# LZNetwork
## LZNetwork的来历
在2020年初，尝试`Swift`开发，于是有了项目中第一个`Swift`版本的网络框架。

它是采用`Moya + RxSwift + HandyJSON`的设计，这是最初版本的使用例子：
```swift
func getDrug() -> Observable<Result<KKMPPlanSearchDrugModel?, LCError>> {
    return Observable.create { [weak self] ob in
        guard let self = self else { return Disposables.create() }
        try? self.request.rx.request(.init(action: .drug))
        .asObservable()
        .mapJSON()
        .verify()
        .mapToObject(KKMPPlanSearchDrugModel.self)
        .subscribe(onNext: { obj in
            ob.onNext(.success(obj))
        }, onError: { error in
            guard let error = error as? LCError else { return }
            ob.onNext(.failure(error))
        }, onCompleted: nil, onDisposed:nil).disposed(by: self.dispose)
    return Disposables.create()
}
```
在之前OC时代，我一直在使用`ReactCocoa`，本着对`响应式`开发的迷恋加上我的蜜汁自信，我尝试去封装出了自己认为还不错，可以满足需求，但四不像的网络框架。

它的使用有许多弊端，我接下来会列出来：
- 方法使用繁琐
- 不支持网关处理单端登录（随着版本迭代暴露出的问题）
- 全局事件抛出机制繁琐
- 对RxSwift依赖严重

随着`Flutter`的流行，我们新启动的项目全部`All in flutter`。老项目处于一个日常维护迭代，发版频率大概一年一次。

随着这次`Swift5.9`的更新，`HandyJSON`毫无征兆的崩溃了。方案一是采用`Codable`替换`HandyJSON`框架，但真正在实际执行中，发现自己4年前作为一个Swift小白写的那些垃圾代码，改动起来是真要命。于是采取了方案二，通过修改cocoapods配置，暂时解决了这一崩溃问题。
```ruby
if target.name == 'HandyJSON'
    target.build_configurations.each do |config|
    config.build_settings['SWIFT_COMPILATION_MODE'] = 'incremental'
    end
end
```

现在回头看之前自己写的代码，就像接手别人的代码一样，那种感觉，就像一坨翔。虽然三年多没写Swift，但还是想尝试把网络框架替换掉。

这就是LZNetwork的由来，虽然它目前看来很简单，但使用它可以进行更深层次的二次开发，它对未来业务的扩展也更加灵活，使用方式也更加简单。

## Cocodpods
```ruby
pod 'LZNetwork'
```

## Package
```swift
dependencies: [
    .package(url: "https://github.com/coder-cjl/LZNetwork.git", .upToNextMajor(from: "0.0.1"))
]
```

## 优势
- 通过对`Moya`的二次封装，调用更加方便。
- 将`Moya`与`Alamofire`的`Error`整合，错误处理标准化
- 保持了`PluginType`的支持
- 规定了`Env`网络配置管理，配置网络化，后台化，定制化。
- `await async`支持


## Example

### 网络配置
#### json
首先要先从自己的服务端加载网络配置，网络配置接口参数返回规则如下
```json
{
    "env":{dev}{test}{uat}{prod},
    "dev": {
        "api_url": "xxx",
        "xxx": "xxx",
    },
    "test": {
        "api_url": "xxx",
        "xxx": "xxx",
    },
    "uat": {
        "api_url": "xxx",
        "xxx": "xxx",
    },
    "prod": {
        "api_url": "xxx",
        "xxx": "xxx",
    },
}
```
字段`env`为当前选择的网络环境，默认为四套环境，其中，`dev test uat prod`为默认字段，不可以随意更改。

但是env变量中的json字段，可以根据自身的业务需求合理配置。

#### 加载配置
在程序启动的合适时机加载网络配置，支持缓存，默认不开启。

```swift
LZEnv.default.loadConfig("url", loadCache: true)
```
当开启缓存配置后，默认会去加载缓存，不会进行网络请求。只有当缓存为nil时，才会主动去进行网络请求。

```swift
public func loadConfig( _ url: String, loadCache: Bool = false) -> Void {
    /// 如果有缓存策略
    if loadCache,
        let cacheString = UserDefaults.standard.string(forKey: url),
        let cachedJSON = cacheString.lz.asJSONObject() {
        setGlobalURLConfig(value: cachedJSON)
        return
    }
        
    let semaphore = DispatchSemaphore(value: 0)
        
    AF.request(url).response(queue: .global(qos: .userInteractive), completionHandler: { response in
        if let data = response.data, let value = try? data.lz.asJSONObject() as? [String: Any] {
            LZEnv.default.setGlobalURLConfig(value: value)
            if (loadCache) {
                if let valueString = value.lz.asString() {
                    UserDefaults.standard.set(valueString, forKey: url)
                }
            }
        }
        semaphore.signal()
    }).resume()
        
    semaphore.wait()
}
```
当开启缓存配置后，想定期更新网络配置，可以试着在`url`后拼接参数

```
url?r=xxxx
```
其中r=xxx是你的缓存策略，可以以天为单位，也可以以周或者月为单位。


#### 切换网络环境
```swift
/// 切换当前环境
public func changeCurrentEnv(env: LZEnvEnum) {
    if let value = globalURLConfig?[env.rawValue] as? [String: Any] {
        currentURLConfig = value
    }
}
```
为了应对开发和测试环节不同环境的切换，提供了切换环境的func，方便开发与调试。


### 数据转模型
采用的是`Codable`系统方案，随着Swift的更新迭代以及我的使用体验，`Codable`已经可以胜任日常的开发工作。

### 网络请求

#### 配置 LZTargetType
```swift
public protocol LZTargetType: TargetType { }

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
```
可以在extension中配置项目的全局参数，如accessToken等字段，也可以在PluginType中设置

#### Api
```swift

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
```
支持`enum`，`struct`，`class`三种类型使用，只需要遵守`LZTargetType`协议

#### 支持 await async

```swift
_Concurrency.Task {
    let result = await LZRequest<User>().request(TestTargetApi.login("123", "123"))
    switch result {
    case .success(let t):
        print(t?.name ?? "")
    case .failure(let error):
        print(error.errorDescription ?? "")
    }
}
```
#### 支持 block
```swift
LZRequest().request(target: TestTargetApi.sms("123"), type: User.self) { result in
    switch result {
    case .success(let user):
        print(user?.name ?? "")
    case .failure(let error):
        print(error.errorDescription ?? "")
    }
}
``` 

#### List Model
```swift
_Concurrency.Task {
    let result = await LZRequest<[List]>().request(TestTargetApi.list)
    switch result {
    case .success(let list):
        print(list?.count ?? "0")
    case .failure(let error):
        print(error.errorDescription ?? "")
    }
}
```

#### 支持 get 缓存
```swift
_Concurrency.Task {
    let result = await LZRequest<[List]>(plugins:[LZGetwayPlugin(), LZCachePlugin()]).request(TestTargetApi.list)
    switch result {
    case .success(let list):
        print(list?.count ?? "0")
    case .failure(let error):
        print(error.errorDescription ?? "")
    }
}
```

#### 更多
更多使用场景，请查看[Example](https://github.com/coder-cjl/LZNetwork)。
如果您有更好的建议或者方案，欢迎[issues](https://github.com/coder-cjl/LZNetwork/issues)反馈🤝。

## Author

coder-cjl, cjlsire@126.com

## License

LZNetwork is available under the MIT license. See the LICENSE file for more info.
