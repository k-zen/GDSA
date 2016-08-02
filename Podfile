platform :ios, '9.0'
use_frameworks!

workspace 'GDSA'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = "NO"
        end
    end
end

target "GDSA" do
    pod 'Mapbox-iOS-SDK'
    pod 'SCLAlertView'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
end
