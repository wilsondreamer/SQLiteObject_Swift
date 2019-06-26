#
# Be sure to run `pod lib lint SQLiteObject.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SQLiteObject'
  s.version          = '0.1.0'
  s.summary          = 'SQLite简易封装库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  简单的封装操作数据库,用对象模式来操作数据表的操作,包括查询、保存、删除
                       DESC

  s.homepage         = 'https://github.com/wilsondreamer/SQLiteObject_Swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wilson' => 'wsn7156@gmail.com' }
  s.source           = { :git => 'https://github.com/wilsondreamer/SQLiteObject_Swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SQLiteObject/Classes/*'
  
  # s.resource_bundles = {
  #   'SQLiteObject' => ['SQLiteObject/Assets/*.png']
  # }
  s.swift_version = '4.0'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SQLite.swift', '~> 0.11.4'
end
