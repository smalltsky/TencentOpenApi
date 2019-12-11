Pod::Spec.new do |s|
  s.name                = "TencentOpenApi"
  s.version             = "3.3.7"
  s.summary             = "The Official iOS SDK of Tencent Open API."
  s.homepage            = "http://wiki.open.qq.com"
  s.license             = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright (c) 2014 Tencent. All rights reserved.
      LICENSE
  }
  s.author              = { "OpenQQ" => "opensupport@qq.com" }
  s.platform            = :ios
  s.requires_arc        = true

  s.source              = { :git=> "https://github.com/smalltsky/TencentOpenApi.git", :tag => "#{s.version}" }
  s.xcconfig            = { "FRAMEWORK_SEARCH_PATHS" => "$(inherited)" }

  s.libraries      = 'iconv', 'z', 'c++', 'sqlite3'
  s.frameworks     = 'Security', 'SystemConfiguration', 'CoreGraphics', 'CoreTelephony'

  s.vendored_frameworks = 'SDK/TencentOpenAPI.framework'
  s.source_files = 'SDK/TencentOpenAPI.framework/Headers/**/*.h'

end
