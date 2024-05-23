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

Features
- [x] URLCache Plugin
- [x] Concurrency
- [x] Decodable

## Example

## 网络配置
在使用网络请求功能前，首先要先从自己的服务端加载网络配置,网络配置接口参数返回规则如下:
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

### await sync
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
### 

## Author

coder-cjl, cjlsire@126.com

## License

LZNetwork is available under the MIT license. See the LICENSE file for more info.
