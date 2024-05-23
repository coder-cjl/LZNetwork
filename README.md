# LZNetwork

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

## Features

- [x] URLCache Plugin
- [x] Concurrency
- [x] Decodable

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


### 数据转模型

采用的是`Codable`系统方案，随着Swift的更新迭代以及我的使用体验，`Codable`已经可以胜任日常的开发工作。

### 网络请求

#### 配置 LZTargetType
```swift
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
可以在extension中配置项目的全局参数，如accessToken等字段，也可以在LZRequest(plugins:[])中设置

#### await async

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
#### block
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

## Author

coder-cjl, cjlsire@126.com

## License

LZNetwork is available under the MIT license. See the LICENSE file for more info.
