Pod::Spec.new do |s|
s.name = 'SGImageBrowser'
s.version = '1.0.0'
s.license = 'MIT'
s.summary = 'Browser a imageViews image easily.'
s.homepage = 'https://github.com/Shanguo/SGImageBrowser'
s.authors = { '刘山国' => '857363312@qq.com' }
s.source = { :git => 'https://github.com/shanguo/SGImageBrowser.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '8.0'
s.source_files = 'SGImageBrowser/SGImageBrowser/**/*.{h,m}'
s.resources = 'SGImageBrowser/SGImageBrowser/**/*.{png,xib}'
s.dependency 'MBProgressHUD', '~> 1.1.0'
s.dependency 'SDWebImage', '~> 4.3.0'
end

