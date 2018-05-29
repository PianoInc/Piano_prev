platform :ios, '10.0'

def common
    pod 'SnapKit'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RealmSwift'
end

# Pods for Piano
target 'Piano' do
    use_frameworks!
    common
    pod 'SwiftyJSON'
    pod 'FBSDKLoginKit'
    pod 'CryptoSwift'
end

# Pods for widget
#target 'widget' do
#    use_frameworks!
#    common
#end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
			config.build_settings['GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS'] = 'NO'
        end
    end
end
