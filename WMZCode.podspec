Pod::Spec.new do |s|

  s.name         = "WMZCode"
  s.version      = "1.0.0"
  s.license      = "Copyright (c) 2018年 WMZ. All rights reserved."
  s.summary      = "滑块验证"
  s.description  = <<-DESC 
                    四种验证
                   DESC
  s.homepage     = "https://github.com/wwmz/WMZCode"
  s.license      = "MIT"
  s.author       = { "wmz" => "925457662@qq.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/wwmz/WMZCode.git", :tag => "1.0.0" }
  s.source_files = "WMZCode/WMZCode/**/*.{h,m}"
  s.framework = 'UIKit'
  
end
