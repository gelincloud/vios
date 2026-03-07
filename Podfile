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
      # Fix deployment target
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end

      # Fix for Xcode 15+ and clang errors with -G option
      # This suppresses the "unsupported option '-G'" error from BoringSSL/gRPC
      config.build_settings['OTHER_CFLAGS'] ||= ['$(inherited)']
      config.build_settings['OTHER_CFLAGS'] << '-Wno-unused-command-line-argument'

      # Suppress warnings as errors
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
    end
  end
end
