source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target "Recognition" do
  pod 'SnapKit', '~> 0.22.0'
  pod 'DateTools'
  pod 'EVCloudKitDao', '~> 2.20.2'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
