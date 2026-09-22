#
# wechat_open_share — bridges official WeChat OpenSDK (no Flutter WeChat plugins).
#
Pod::Spec.new do |s|
  s.name             = 'wechat_open_share'
  s.version          = '0.1.0'
  s.summary          = 'WeChat OpenSDK share bridge for Flutter'
  s.description      = <<-DESC
Flutter MethodChannel bridge to the official WeChat OpenSDK for sharing.
                       DESC
  s.homepage         = 'https://github.com/clg/blessing_share'
  s.license          = { :type => 'MIT' }
  s.author           = { 'clg' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  # Official WeChat OpenSDK (no pay). Host must configure Universal Link + URL Scheme.
  s.dependency 'WechatOpenSDK-XCFramework', '~> 2.0.4'
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
