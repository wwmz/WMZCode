Pod::Spec.new do |s|

  s.name         = "WMZCode"
  s.version      = "1.0.2"
  s.license      = "Copyright (c) 2018年 WMZ. All rights reserved."
  s.summary      = "滑块验证"
  s.description  = <<-DESC 
                    四种验证
                   DESC
  s.homepage     = "https://github.com/wwmz/WMZCode"
  s.license      = {:type => "MIT", :file => "LICENSE" }
  s.author       = { "wmz" => "925457662@qq.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/wwmz/WMZCode.git",:tag => s.version.to_s}
  s.source_files = "WMZCode/WMZCode/**/*.{h,m}"
  s.requires_arc = true  
end
