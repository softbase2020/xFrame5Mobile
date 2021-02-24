Pod::Spec.new do |spec|
  spec.name         = "xFrame5Mobile"
  spec.version      = "1.1.4"
  spec.summary      = "xFrame5 용 모바일앱 프레임워크"
  spec.description  = "(주)소프트베이스에서 개발한 UI 통합 솔루션인 xFrame5의 모바일용 iOS앱 개발을 위한 프레임워크"
  spec.homepage     = "http://www.xframe.co.kr"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "hansne" => "hans@directionsoft.com" }
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/softbase2020/xFrame5Mobile.git", :tag => "#{spec.version}" }
  spec.source_files  = 'xFrame5Mobile/Delegate/**/*.{h,m}', 'xFrame5Mobile/Classes/**/*.{h,m}','xFrame5Mobile/xFrame5Mobile/*.h'
  spec.resources = 'xFrame5Mobile/Classes/**/*.xib'
end
