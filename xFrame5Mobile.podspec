Pod::Spec.new do |spec|
  spec.name         = "xFrame5Mobile"
  spec.version      = "1.1.0"
  spec.summary      = "xFrame5 용 모바일앱 프레임워크"
  spec.description  = "(주)소프트베이스에서 개발한 UI 통합 솔루션인 xFrame5의 모바일용 iOS앱 개발을 위한 프레임워크"
  spec.homepage     = "http://www.xframe.co.kr"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "hansne" => "hans@directionsoft.com" }
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/softbase2020/xFrame5Mobile.git", :tag => "#{spec.version}" }
  spec.source_files  = 'xFrame5Mobile/xFrame5Mobile/*.h'

  spec.subspec 'Delegate' do |ss|
    ss.source_files = 'xFrame5Mobile/Delegate/*.{h,m}'
  end

  spec.subspec 'Controller' do |ss|
    ss.source_files = 'xFrame5Mobile/Classes/Controller/*.{h,m}'
  end

  spec.subspec 'Category' do |ss|
    ss.source_files = 'xFrame5Mobile/Classes/Category/*.{h,m}'
  end

  spec.subspec 'Common' do |ss|
    ss.source_files = 'xFrame5Mobile/Classes/Common/*.{h,m}'
  end

  spec.subspec 'CommonView' do |ss|
    ss.source_files = 'xFrame5Mobile/Classes/CommonView/**/*.{h,m}'
  end

  spec.subspec 'Library' do |ss|
    ss.source_files = 'xFrame5Mobile/Classes/Library/**/*.{h,m}'
  end

end
