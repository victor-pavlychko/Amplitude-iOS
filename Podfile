source 'https://github.com/CocoaPods/Specs.git'

xcodeproj 'Amplitude'

def import_pods
  pod 'OCMock', '~> 3.1.1'
end

target :ios_test do
  link_with "AmplitudeTests"
  platform :ios, '6.0'
  import_pods
end

target :osx_test do
  link_with "AmplitudeTestsOSX"
  platform :osx, '10.7'
  import_pods
end

post_install do |installer|
  installer.project.targets.each do |target|
    puts target.name
  end
end
