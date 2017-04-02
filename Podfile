# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GolfTourney' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod ‘Firebase/Auth’
  pod ‘Firebase/Storage’
  pod ‘GoogleSignIn’, ‘4.0.1’
  pod 'FacebookCore'
  pod 'THCalendarDatePicker', '~> 1.2.6'
  pod 'ALGridView'
pod 'FacebookLogin'
pod 'FacebookShare'
pod 'GooglePlaces'
pod 'JSQMessagesViewController'
#pod 'KIF'
#pod 'Nimble'
pod 'SidebarOverlay'
pod 'RealmSwift'
  # Pods for GolfTourney

  target 'GolfTourneyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GolfTourneyUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.1'
    end
  end
end
