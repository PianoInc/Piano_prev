platform :ios, '10.0'

def common
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RealmSwift'
end

# Pods for Piano
target 'Piano' do
    use_frameworks!
    pod 'CryptoSwift'
    pod 'GoogleMaps'
    common
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
