Pod::Spec.new do |s|
  s.name                = "TencentOpenApiSDK"
  s.version             = "3.3.3"
  s.summary             = "The Official iOS SDK of Tencent Open API."
  s.homepage            = "http://wiki.open.qq.com"
  s.license             = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright (c) 2014 Tencent. All rights reserved.
      LICENSE
  }
  s.author              = { "OpenQQ" => "opensupport@qq.com" }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source              = { :git=> "https://github.com/candyan/TencentOpenApiSDK.git", :tag => "#{s.version}" }
  s.xcconfig            = { "FRAMEWORK_SEARCH_PATHS" => "$(inherited)" }

  s.vendored_frameworks = 'SDK/TencentOpenAPI.framework'
  s.ios.frameworks = 'CoreTelephony', 'SystemConfiguration'
  s.ios.libraries = 'z', 'sqlite3.0', 'c++', 'iconv'

end
