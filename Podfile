source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

target "Recognition" do
  pod 'SnapKit'
  pod 'DateToolsSwift'
end

 post_install do |installer|
     installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
             config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
         end
     end
 end
