# Uncomment the next line to define a global platform for your project
platform :ios, '10.3'
source "https://gitlab.linphone.org/BC/public/podspec.git"

target 'ChengLine' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LineLA
  pod 'SQLite.swift', '~> 0.11.6'
  pod 'CocoaMQTT'
  pod 'linphone-sdk', '~> 4.1-305-ge928aae'
  target 'ChengLineTests' do
    inherit! :search_paths
    # Pods for testing
  end

  #target 'ChengLineUITests' do
    #inherit! :search_piaths
    # Pods for testing
  #end

end
