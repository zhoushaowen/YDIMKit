Pod::Spec.new do |s|

  s.name         = "YDIMKit"

  s.version      = "0.0.1"

  s.homepage      = 'https://github.com/zhoushaowen/YDIMKit'

  s.ios.deployment_target = '8.0'

  s.summary      = "IM UI Component"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Zhoushaowen" => "348345883@qq.com" }

  s.source       = { :git => "https://github.com/zhoushaowen/YDIMKit.git", :tag => s.version }

  s.source_files  = "YDIMKit/YDIMKit/Controller/*.{h,m}","YDIMKit/YDIMKit/Extension/*.{h,m}","YDIMKit/YDIMKit/Model/*.{h,m}","YDIMKit/YDIMKit/Protocol/*.{h,m}","YDIMKit/YDIMKit/View/*.{h,m}","YDIMKit/YDIMKit/Tool/*.{h,m}"
  
  s.resources  = "YDIMKit/YDIMKit/Source/chat.bundle"
  
  s.requires_arc = true

  s.dependency 'SWExpandResponse'
  s.dependency 'SWExtension'


end