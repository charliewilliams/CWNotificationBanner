#
# Be sure to run `pod lib lint CWNotificationBanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CWNotificationBanner"
  s.version          = "0.1.0"
  s.summary          = "You want a nice iOS Push Notification UI to display popover banners? Here it is."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
        CWNotificationBanner provides an easy way to mimic the iOS push notification UI while your app is active.
                       DESC

  s.homepage         = "https://github.com/charliewilliams/CWNotificationBanner"
  # s.screenshots    = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Charlie Williams" => "c@charliewilliams.org" }
  s.source           = { :git => "https://github.com/charliewilliams/CWNotificationBanner.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/buildsucceeded'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CWNotificationBanner/Classes/**/*'
  s.resource_bundles = {
    'CWNotificationBanner' => ['CWNotificationBanner/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'SwiftyTimer', '~> 1.4'
end
