platform :ios, '8.0'
install! 'cocoapods',
         :deterministic_uuids => false

target 'DNGPS' do

    pod 'DNFeature', :path => './DNFeature'
    pod 'DNFoundation', :path => './DNFoundation'

    pod 'FMDB', '~> 2.7.2',:inhibit_warnings => true
    pod 'Masonry', '~> 1.1.0',:inhibit_warnings => true
    pod 'JLRoutes', '~> 2.1'
    pod 'SDWebImage', '~> 4.3.2'
    pod 'MBProgressHUD', '~> 1.1.0'
    pod 'AVOSCloud', '~> 9.0.0',:inhibit_warnings => true
    pod 'MMDrawerController', '~> 0.6.0'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 8.0
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
            end
        end
    end
end
