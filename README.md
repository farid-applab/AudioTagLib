# AudioTagLib

[![CI Status](https://img.shields.io/travis/farid-applab/AudioTagLib.svg?style=flat)](https://travis-ci.org/farid-applab/AudioTagLib)
[![Version](https://img.shields.io/cocoapods/v/AudioTagLib.svg?style=flat)](https://cocoapods.org/pods/AudioTagLib)
[![License](https://img.shields.io/cocoapods/l/AudioTagLib.svg?style=flat)](https://cocoapods.org/pods/AudioTagLib)
[![Platform](https://img.shields.io/cocoapods/p/AudioTagLib.svg?style=flat)](https://cocoapods.org/pods/AudioTagLib)

### TagLib Audio Meta-Data Library

http://taglib.org/

TagLib is a library for reading and editing the meta-data of several
popular audio formats. Currently it supports both ID3v1 and [ID3v2][]
for MP3 files, [Ogg Vorbis][] comments and ID3 tags and Vorbis comments
in [FLAC][], MPC, Speex, WavPack, TrueAudio, WAV, AIFF, MP4 and ASF
files.

  [ID3v2]: http://www.id3.org 
  [Ogg Vorbis]: http://vorbis.com/
  [FLAC]: https://xiph.org/flac/
  
### Credits

* The Objective C Wrapper is based on [hisaac TagLibKit's](https://github.com/hisaac/TagLibKit/tree/main/Sources) implementation.
* The Objective C Wrapper is based on [lemonhead94 TagLibIOS's](https://github.com/lemonhead94/TagLibIOS/tree/master/TagLibIOS) implementation.
* The Objective C Wrapper is based on [eni9889 TagLib-Objc's](https://github.com/eni9889/TagLib-ObjC/tree/master/taglib-objc) implementation.
* [TagLib version 1.11.1](https://github.com/taglib/taglib/releases/tag/v2.0.2) from GitHub is compiled... 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

**Swift Example:**

```swift
let metadata = TaglibWrapper.getMetadata(audioFilePath.path)
let artwork = TaglibWrapper.getArtwork(audioFilePath.path)
TaglibWrapper.setMetadata(track.url?.path, dictionary: ["TITLE" : "New Title"])
```

<!--*Currently Flac, WAV, MPEG/MP3, MP4, and M4A wrapper are included...*-->

## Requirements

## Installation

TagLibIOS is available through [CocoaPods](https://cocoapods.org). In order to compile this correctly one has to add `use_frameworks!` to the Podfile! 
To install it, simply add the following lines to your Podfile:

```ruby
pod 'AudioTagLib'
```

## Author

farid-applab, farid@applabltd.co

## License

<!--AudioTagLib is available under the MIT license. See the LICENSE file for more info.-->
TagLib is distributed under the [GNU Lesser General Public License][]
(LGPL) and [Mozilla Public License][] (MPL). Essentially that means that
it may be used in proprietary applications, but if changes are made to
TagLib they must be contributed back to the project. Please review the
licenses if you are considering using TagLib in your project.

  [GNU Lesser General Public License]: http://www.gnu.org/licenses/lgpl.html
  [Mozilla Public License]: http://www.mozilla.org/MPL/MPL-1.1.html
