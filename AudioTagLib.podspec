#
# Be sure to run `pod lib lint AudioTagLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AudioTagLib'
  s.version          = '0.1.0'
  s.summary          = 'AudioTagLib is a wrapper for the TagLib Audio Meta-Data Library.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  **AudioTagLib Audio Meta-Data Library**

#  *http://TagLibIOS.org/
  *http://taglib.org/

  AudioTagLib is a library for reading and editing the meta-data of several
  popular audio formats. Currently it supports both ID3v1 and [ID3v2](http://www.id3.org)
  for MP3 files, [Ogg Vorbis](http://vorbis.com/) comments and ID3 tags and Vorbis comments
      in [FLAC](https://xiph.org/flac/), MPC, Speex, WavPack, TrueAudio, WAV, AIFF, MP4 and ASF
      files.
                       
                       DESC

  s.homepage         = 'https://github.com/farid-applab/AudioTagLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'farid-applab' => 'farid@applabltd.co' }
  s.source           = { :git => 'https://github.com/farid-applab/AudioTagLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  
    s.swift_version = '5.0'
    s.platforms = {
        "ios": "12.0"
    }
  
  #s.source_files = 'AudioTagLib/Classes/**/*'
  
#  s.module_map = 'AudioTagLib/AudioTagLib.modulemap'
  s.module_map = 'AudioTagLib/Framework/AudioTagLib.modulemap'

  s.public_header_files = ['AudioTagLib/Framework/AudioTagLib-umbrella.h', 'AudioTagLib/Classes/iOSWrapper/*.h']
  s.private_header_files = 'AudioTagLib/Classes/taglib/**/*.h'
  s.source_files = ['AudioTagLib/Framework/AudioTagLib-umbrella.h', 'AudioTagLib/Classes/**/**/*.{h,cpp,mm}']
  s.library = 'c++'
  s.xcconfig = {
      'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++14',
      'CLANG_CXX_LIBRARY' => 'libc++'
  }
  
  # s.resource_bundles = {
  #   'AudioTagLib' => ['AudioTagLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
