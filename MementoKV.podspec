#
# Be sure to run `pod lib lint MementoKV.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MementoKV'
  s.version          = '0.1.2'
  s.summary          = '一个轻量级的 iOS 本地键值存储库，基于 FMDB 封装。'

  s.homepage         = 'https://github.com/iAmMccc'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iAmMccc' => 'Mccc' }
  s.source           = { :git => 'https://github.com/iAmMccc/MementoKV.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'MementoKV/Classes/**/*'
  s.dependency 'FMDB'

end
