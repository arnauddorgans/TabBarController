#
# Be sure to run `pod lib lint TabBarController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TabBarController'
  s.version          = '1.0'
  s.summary          = 'TabBarController acts like a UITabBarController that allows you to customize TabBar, frame and animations.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TabBarController acts like a UITabBarController that allows you to customize TabBar, frame and animations.
                       DESC

  s.homepage         = 'https://github.com/Arnoymous/TabBarController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Arnoymous' => 'arnaud.dorgans@gmail.com' }
  s.source           = { :git => 'https://github.com/Arnoymous/TabBarController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/arnauddorgans'

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'TabBarController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TabBarController' => ['TabBarController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
