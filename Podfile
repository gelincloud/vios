target "veivo" do
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
pod 'AFNetworking', '~> 4.0'
pod 'Masonry', '~> 1.0.2'
pod 'CTAssetsPickerController', '~> 3.3.0'
pod 'FBSDKCoreKit','~> 17.0'
pod 'FBSDKLoginKit','~> 17.0'
pod 'FBSDKShareKit','~> 17.0'
use_frameworks! :linkage => :static
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'GoogleSignIn'
#pod 'TwitterKit' # TwitterKit is deprecated and has compatibility issues
#pod "Weibo_SDK", :git => "https://github.com/sinaweibosdk/weibo_ios_sdk.git"
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end
