
Pod::Spec.new do |s|
  s.name             = 'LZNetwork'
  s.version          = '0.0.1'
  s.summary          = 'LZNetwork.'
  
  s.description      = <<-DESC
          swift 版本的网络请求封装，依赖于Moya进行二次装
                       DESC

  s.homepage         = 'https://github.com/coder-cjl/LZNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'coder-cjl' => 'cjlsire@126.com' }
  s.source           = { :git => 'https://github.com/coder-cjl/LZNetwork.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.visionos.deployment_target = '1.0'
  s.watchos.deployment_target = '6.0'
  s.swift_versions = ['5']
  
  s.source_files = 'Source/**/*'
  
  # s.resource_bundles = {
  #   'LZNetwork' => ['LZNetwork/Assets/*.png']
  # }
  
   s.frameworks = 'UIKit', 'Foundation'
   s.dependency 'Moya', '~> 15.0.0'
   s.dependency 'Alamofire', '~> 5.9.0'
end
