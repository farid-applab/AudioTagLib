//
//  TaglibWrapper.m
//  Taglib-iOS
//
//  Created by md farid on 2/11/24.
//

#import <Foundation/Foundation.h>

#include <iostream>
#include <iomanip>
#include <stdio.h>
#import <tag.h>
#import <fileref.h>
#import <rifffile.h>
#import <wavfile.h>
#import <aifffile.h>
#import <mpegfile.h>
#import <mp4file.h>
#include <flacfile.h>

#import <tstring.h>
#import <tstringlist.h>

#import <chapterframe.h>
#import <tpropertymap.h>
#import <textidentificationframe.h>
#import <tfilestream.h>

#include "mpegfile.h"
#include "id3v2tag.h"
#include "id3v2frame.h"
#include "id3v2header.h"
#include "attachedpictureframe.h"

#import "TaglibWrapper.h"

using namespace TagLib;
using namespace std;

 @implementation TaglibWrapper

 + (nullable NSString *)getTitle:(NSString *)path
 {
     TagLib::FileRef fileRef(path.UTF8String);
     if (fileRef.isNull()) {
         return nil;
     }

     TagLib::Tag *tag = fileRef.tag();
     if (!tag) {
         return nil;
     }
     NSString *value = [NSString stringWithUTF8String:tag->title().toCString()];
     return value;
 }

 + (nullable NSString *)getComment:(NSString *)path
 {
     TagLib::FileRef fileRef(path.UTF8String);
     if (fileRef.isNull()) {
         cout << "FileRef is nil for: " << path.UTF8String << endl;
         return nil;
     }

     TagLib::Tag *tag = fileRef.tag();
     if (!tag) {
         cout << "Tag is nil" << endl;
         return nil;
     }
     NSString *value = [NSString stringWithUTF8String:tag->comment().toCString()];
     return value;
 }

 + (nullable NSMutableDictionary *)getMetadata:(NSString *)path
 {
     NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

     TagLib::FileRef fileRef(path.UTF8String);
     if (fileRef.isNull()) {
         return nil;
     }

     TagLib::Tag *tag = fileRef.tag();
     if (!tag) {
         return nil;
     }
 //    cout << "-- TAG (basic) --" << endl;
 //    cout << "title   - \"" << tag->title()   << "\"" << endl;
 //    cout << "artist  - \"" << tag->artist()  << "\"" << endl;
 //    cout << "album   - \"" << tag->album()   << "\"" << endl;
 //    cout << "year    - \"" << tag->year()    << "\"" << endl;
 //    cout << "comment - \"" << tag->comment() << "\"" << endl;
 //    cout << "track   - \"" << tag->track()   << "\"" << endl;
 //    cout << "genre   - \"" << tag->genre()   << "\"" << endl;

     TagLib::RIFF::WAV::File *waveFile = dynamic_cast<TagLib::RIFF::WAV::File *>(fileRef.file());

     NSString *title = [TaglibWrapper stringFromWchar:tag->title().toCWString()];

     // if title is blank, check the wave info tag instead
     if (title == nil && waveFile) {
         title = [TaglibWrapper stringFromWchar:waveFile->InfoTag()->title().toCWString()];
     }
     [dictionary setValue:title ? : @"" forKey:@"TITLE"];

     NSString *artist = [TaglibWrapper stringFromWchar:tag->artist().toCWString()];

     if ((artist == nil || [artist isEqualToString:@""]) && waveFile) {
         artist = [TaglibWrapper stringFromWchar:waveFile->InfoTag()->artist().toCWString()];
     }
     [dictionary setValue:artist ? : @"" forKey:@"ARTIST"];

     NSString *album = [TaglibWrapper stringFromWchar:tag->album().toCWString()];
     if ((album == nil || [album isEqualToString:@""]) && waveFile) {
         album = [TaglibWrapper stringFromWchar:waveFile->InfoTag()->album().toCWString()];
     }
     [dictionary setValue:album ? : @"" forKey:@"ALBUM"];

     NSString *year = [NSString stringWithFormat:@"%u", tag->year()];
     [dictionary setValue:year forKey:@"YEAR"];

     NSString *comment = [TaglibWrapper stringFromWchar:tag->comment().toCWString()];
     if ((comment == nil || [comment isEqualToString:@""]) && waveFile) {
         comment = [TaglibWrapper stringFromWchar:waveFile->InfoTag()->comment().toCWString()];
     }
     [dictionary setValue:comment ? : @"" forKey:@"COMMENT"];

     NSString *track = [NSString stringWithFormat:@"%u", tag->track()];
     [dictionary setValue:track ? : @"" forKey:@"TRACK"];

     NSString *genre = [TaglibWrapper stringFromWchar:tag->genre().toCWString()];
     if ((genre == nil || [genre isEqualToString:@""]) && waveFile) {
         genre = [TaglibWrapper stringFromWchar:waveFile->InfoTag()->genre().toCWString()];
     }
     [dictionary setValue:genre ? : @"" forKey:@"GENRE"];

     TagLib::PropertyMap tags = fileRef.file()->properties();

     // scan through the tag properties where all the other id3 tags will be kept
     // add those as additional keys to the dictionary
     //cout << "-- TAG (properties) --" << endl;
     for (TagLib::PropertyMap::ConstIterator i = tags.begin(); i != tags.end(); ++i) {
         for (TagLib::StringList::ConstIterator j = i->second.begin(); j != i->second.end(); ++j) {
             // cout << i->first << " - " << '"' << *j << '"' << endl;

             NSString *key = [TaglibWrapper stringFromWchar:i->first.toCWString()];
             NSString *object = [TaglibWrapper stringFromWchar:j->toCWString()];

             if (key != nil && object != nil) {
                 [dictionary setValue:object ? : @"" forKey:key];
             }
         }
     }
     return dictionary;
 }

 + (bool)setMetadata:(NSString *)path
          dictionary:(NSDictionary *)dictionary
 {
     TagLib::FileRef fileRef(path.UTF8String);

     if (fileRef.isNull()) {
         cout << "Error: TagLib::FileRef.isNull: Unable to open file:" << path.UTF8String << endl;
         return false;
     }

     TagLib::Tag *tag = fileRef.tag();
     if (!tag) {
         cout << "Unable to create tag" << endl;
         return false;
     }

     // also duplicate the data into the INFO tag if it's a wave file
     TagLib::RIFF::WAV::File *waveFile = dynamic_cast<TagLib::RIFF::WAV::File *>(fileRef.file());

     // these are the non standard tags
     TagLib::PropertyMap tags = fileRef.file()->properties();

     for (NSString *key in [dictionary allKeys]) {
         NSString *value = [dictionary objectForKey:key];

         if ([key isEqualToString:@"TITLE"]) {
             tag->setTitle(value.UTF8String);
             // also set InfoTag for wave
             if (waveFile) {
                 waveFile->InfoTag()->setTitle(value.UTF8String);
             }
         } else if ([key isEqualToString:@"ARTIST"]) {
             tag->setArtist(value.UTF8String);
             if (waveFile) {
                 waveFile->InfoTag()->setArtist(value.UTF8String);
             }
         } else if ([key isEqualToString:@"ALBUM"]) {
             tag->setAlbum(value.UTF8String);
             if (waveFile) {
                 waveFile->InfoTag()->setAlbum(value.UTF8String);
             }
         } else if ([key isEqualToString:@"YEAR"]) {
             tag->setYear(value.intValue);
             if (waveFile) {
                 waveFile->InfoTag()->setYear(value.intValue);
             }
         } else if ([key isEqualToString:@"TRACK"]) {
             tag->setTrack(value.intValue);
             if (waveFile) {
                 waveFile->InfoTag()->setTrack(value.intValue);
             }
         } else if ([key isEqualToString:@"COMMENT"]) {
             tag->setComment(value.UTF8String);
             if (waveFile) {
                 waveFile->InfoTag()->setComment(value.UTF8String);
             }
         } else if ([key isEqualToString:@"GENRE"]) {
             tag->setGenre(value.UTF8String);
             if (waveFile) {
                 waveFile->InfoTag()->setGenre(value.UTF8String);
             }
         } else {
             TagLib::String tagKey = TagLib::String(key.UTF8String);
             tags.replace(TagLib::String(key.UTF8String), TagLib::StringList(value.UTF8String));
         }
     }

     bool result = fileRef.save();

     return result;
 }

 void printTags(const TagLib::PropertyMap &tags)
 {
     unsigned int longest = 0;
     for (TagLib::PropertyMap::ConstIterator i = tags.begin(); i != tags.end(); ++i) {
         if (i->first.size() > longest) {
             longest = i->first.size();
         }
     }
     cout << "-- TAG (properties) --" << endl;
     for (TagLib::PropertyMap::ConstIterator i = tags.begin(); i != tags.end(); ++i) {
         for (TagLib::StringList::ConstIterator j = i->second.begin(); j != i->second.end(); ++j) {
             cout << left << std::setw(longest) << i->first << " - " << '"' << *j << '"' << endl;
         }
     }
 }

+ (void)printFileTags:(NSString *)path
{
    TagLib::FileRef fileRef(path.UTF8String);
    if (fileRef.isNull()) {
        cout << "Unable to open file: " << path.UTF8String << endl;
        return;
    }

    // Get the properties and print them using printTags
    TagLib::PropertyMap tags = fileRef.file()->properties();
    printTags(tags);
}


 // convenience function to update the comment tag in a file
 + (bool)writeComment:(NSString *)path
              comment:(NSString *)comment
 {
     TagLib::FileRef fileRef(path.UTF8String);

     if (fileRef.isNull()) {
         cout << "Unable to write comment" << endl;
         return false;
     }

     cout << "Updating comment to: " << comment.UTF8String << endl;
     TagLib::Tag *tag = fileRef.tag();
     if (!tag) {
         cout << "Unable to write tag" << endl;
         return false;
     }

     tag->setComment(comment.UTF8String);
     bool result = fileRef.save();
     return result;
 }

 /// markers as chapters in mp3 and mp4 files
 + (NSArray *)getChapters:(NSString *)path
 {
     NSMutableArray *array = [[NSMutableArray alloc] init];

     TagLib::FileRef fileRef(path.UTF8String);
     if (fileRef.isNull()) {
         return nil;
     }

     TagLib::Tag *tag = fileRef.tag();
     if (!tag) {
         return nil;
     }

     TagLib::MPEG::File *mpegFile = dynamic_cast<TagLib::MPEG::File *>(fileRef.file());

     if (!mpegFile) {
         return nil;
     }
     // cout << "Parsing MPEG File" << endl;

     TagLib::ID3v2::FrameList chapterList = mpegFile->ID3v2Tag()->frameList("CHAP");

     for (TagLib::ID3v2::FrameList::ConstIterator it = chapterList.begin();
          it != chapterList.end();
          ++it) {
         TagLib::ID3v2::ChapterFrame *frame = dynamic_cast<TagLib::ID3v2::ChapterFrame *>(*it);
         if (frame) {
             // cout << "FRAME " << frame->toString() << endl;

             if (!frame->embeddedFrameList().isEmpty()) {
                 for (TagLib::ID3v2::FrameList::ConstIterator it = frame->embeddedFrameList().begin(); it != frame->embeddedFrameList().end(); ++it) {
                     // the chapter title is a sub frame
                     if ((*it)->frameID() == "TIT2") {
                         // cout << (*it)->frameID() << " = " << (*it)->toString() << endl;
                         NSString *marker = [TaglibWrapper stringFromWchar:(*it)->toString().toCWString()];

                         marker = [marker stringByAppendingString:[NSString stringWithFormat:@"@%d", frame->startTime()] ];
                         [array addObject:marker];
                     }
                 }
             }
         }
     }

     return array;
 }

 // only works with mp3 files
 + (bool)setChapters:(NSString *)path
               array:(NSArray *)array
 {
     TagLib::FileRef fileRef(path.UTF8String);
     if (fileRef.isNull()) {
         return false;
     }

     TagLib::Tag *tag = fileRef.tag();
     if (!tag) {
         return false;
     }
     TagLib::MPEG::File *mpegFile = dynamic_cast<TagLib::MPEG::File *>(fileRef.file());

     if (!mpegFile) {
         cout << "TaglibWrapper.setChapters: Not a MPEG File" << endl;
         return false;
     }

     // parse array

     // remove CHAPter tags
     mpegFile->ID3v2Tag()->removeFrames("CHAP");

     // add new CHAP tags
     TagLib::ID3v2::Header header;

     // expecting NAME@TIME right now
     for (NSString *object in array) {
         NSArray *items = [object componentsSeparatedByString:@"@"];
         NSString *name = [items objectAtIndex:0];   //shows Description
         int time = [[items objectAtIndex:1] intValue];

         TagLib::ID3v2::ChapterFrame *chapter = new TagLib::ID3v2::ChapterFrame(&header, "CHAP");
         chapter->setStartTime(time);
         chapter->setEndTime(time);

         // set the chapter title
         TagLib::ID3v2::TextIdentificationFrame *eF = new TagLib::ID3v2::TextIdentificationFrame("TIT2");
         eF->setText(name.UTF8String);
         chapter->addEmbeddedFrame(eF);
         mpegFile->ID3v2Tag()->addFrame(chapter);
     }
     bool result = mpegFile->save();
     return result;
 }

 + (NSString *)detectFileType:(NSString *)path
 {
     if (![path.pathExtension isEqualToString:@""]) {
         // NSLog(@"returning via extension %@", path.pathExtension);
         return [path.pathExtension lowercaseString];
     }
     return [TaglibWrapper detectStreamType:path];
 }

 + (NSString *)detectStreamType:(NSString *)path
 {
     /*
     const char *filepath = path.UTF8String;
     TagLib::FileStream *stream = new TagLib::FileStream(filepath);

     if (!stream->isOpen()) {
         NSLog(@"Unable to open FileStream: %@", path);
         delete stream;
         return nil;
     }
     const char *value = nil;

     if (TagLib::MPEG::File::isSupported(stream)) {
         value = "mp3";
     } else if (TagLib::MP4::File::isSupported(stream)) {
         value = "m4a";
     } else if (TagLib::RIFF::WAV::File::isSupported(stream)) {
         value = "wav";
     } else if (TagLib::RIFF::AIFF::File::isSupported(stream)) {
         value = "aif";
     }

     delete stream;

     if (value) {
         // NSLog(@"Returning stream file type: %s", value);
         return [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
     }
      */
     return nil;
 }

 + (NSString *)stringFromWchar:(const wchar_t *)charText
 {
     //used ARC
     return [[NSString alloc] initWithBytes:charText length:wcslen(charText) * sizeof(*charText) encoding:NSUTF32LittleEndianStringEncoding];
 }


+ (nullable NSData *)getArtwork:(NSString *)path {
    NSLog(@"getArtwork obj-c");
    TagLib::FileRef fileRef(path.UTF8String);
    if (fileRef.isNull()) {
        NSLog(@"Unable to open file: %@", path);
        return nil;
    }

    TagLib::MPEG::File *mpegFile = dynamic_cast<TagLib::MPEG::File *>(fileRef.file());
    if (!mpegFile) {
        NSLog(@"File is not a valid MPEG file: %@", path);
        TagLib::FLAC::File *flacFile = dynamic_cast<TagLib::FLAC::File *>(fileRef.file());
        if (flacFile) {
            //Tag *flacTag = flacFile->tag();
            List<TagLib::FLAC::Picture *> pictureList = flacFile->pictureList();
            NSLog(@"pictureList cnt: %d", pictureList.size());
            List<TagLib::FLAC::Picture *>::Iterator it;
            for (it = pictureList.begin(); it != pictureList.end(); ++it){
                TagLib::FLAC::Picture *picture = dynamic_cast<TagLib::FLAC::Picture *>(*it);
                if(picture->type() == TagLib::FLAC::Picture::FrontCover) {
                    TagLib::ByteVector bv = picture->data();
                    return [NSData dataWithBytes:bv.data() length:bv.size()];
                }
            }
        }
        return nil;
    }

    TagLib::ID3v2::Tag *id3v2Tag = mpegFile->ID3v2Tag();
    if (!id3v2Tag) {
        NSLog(@"No ID3v2 tag found in file: %@", path);
        return nil;
    }
  
    TagLib::ID3v2::FrameList pictureFrames = id3v2Tag->frameList("APIC");
    for (auto frame : pictureFrames) {
        if (frame->frameID() == "APIC") {
            auto pictureFrame = dynamic_cast<TagLib::ID3v2::AttachedPictureFrame *>(frame);
            if (pictureFrame) {
                return [NSData dataWithBytes:pictureFrame->picture().data() length:pictureFrame->picture().size()];
            }
        }
    }

    return nil; // No artwork found
}

+ (BOOL)setArtwork:(NSString *)path
           artwork:(NSData *)artwork {
    
    NSString *fileExtension = [path pathExtension].lowercaseString;
    if ([fileExtension isEqualToString:@"mp3"]) {
        return [self setMP3Artwork:artwork forFileAtPath:path];
    } else if ([fileExtension isEqualToString:@"flac"]) {
        return [self setFLACArtwork:artwork forFileAtPath:path];
    } else {
        NSLog(@"Unsupported file format: %@", fileExtension);
        return NO;
    }
}

// Private helper functions
+ (BOOL)setMP3Artwork:(NSData *)artwork
        forFileAtPath:(NSString *)path  {
    
    TagLib::FileRef fileRef(path.UTF8String);
    if (fileRef.isNull()) {
        NSLog(@"Unable to open file: %@", path);
        return NO;
    }

    TagLib::MPEG::File *mpegFile = dynamic_cast<TagLib::MPEG::File *>(fileRef.file());
    if (!mpegFile) {
        NSLog(@"File is not a valid MPEG file: %@", path);
        return NO;
    }

    TagLib::ID3v2::Tag *id3v2Tag = mpegFile->ID3v2Tag(true);  // Create ID3v2 tag if it doesn't exist
    if (!id3v2Tag) {
        NSLog(@"Failed to create or retrieve ID3v2 tag for file: %@", path);
        return NO;
    }

    // Remove any existing "APIC" frames (optional step)
    id3v2Tag->removeFrames("APIC");

    // Create a new APIC frame for the artwork
    TagLib::ID3v2::AttachedPictureFrame *pictureFrame = new TagLib::ID3v2::AttachedPictureFrame();
    pictureFrame->setMimeType([self mimeTypeByGuessingFromData: artwork]);
    TagLib::ByteVector bv = TagLib::ByteVector((const char *)[artwork bytes], (int)[artwork length]);
    pictureFrame->setPicture(bv);
    pictureFrame->setType(TagLib::ID3v2::AttachedPictureFrame::FrontCover); // Set as cover image

    // Add the new frame to the ID3v2 tag
    id3v2Tag->addFrame(pictureFrame);

    // Save the changes to the file
    return mpegFile->save();
}

+ (BOOL)setFLACArtwork:(NSData *)artwork 
         forFileAtPath:(NSString *)path {
    
    TagLib::FileRef fileRef(path.UTF8String);
    if (fileRef.isNull()) {
        NSLog(@"Unable to open file: %@", path);
        return NO;
    }

    TagLib::FLAC::File *flacFile = dynamic_cast<TagLib::FLAC::File *>(fileRef.file());
    if (!flacFile) {
        NSLog(@"File is not a valid FLAC file: %@", path);
        return NO;
    }
    // Remove existing artwork (optional step)
    flacFile->removePictures();

    // Create a new picture block
    TagLib::FLAC::Picture *picture = new TagLib::FLAC::Picture();
    picture->setType(TagLib::FLAC::Picture::FrontCover);  // Set as cover image
    picture->setMimeType([self mimeTypeByGuessingFromData: artwork]);            // Set MIME type, e.g., "image/jpeg"
    TagLib::ByteVector bv = ByteVector((const char *)[artwork bytes], (int)[artwork length]);
    picture->setData(bv);
    // Add the new picture to the FLAC file
    flacFile->addPicture(picture);
    // Save changes to the file
    return flacFile->save();
}


+ (String)mimeTypeByGuessingFromData:(NSData *)data {
    
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];
    
    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    const char swf[3] = {'F', 'W', 'S'};
    const char swc[3] = {'C', 'W', 'S'};
    const char jpg[3] = {static_cast<char>(0xff), static_cast<char>(0xd8), static_cast<char>(0xff)};
    const char psd[4] = {'8', 'B', 'P', 'S'};
    const char iff[4] = {'F', 'O', 'R', 'M'};
    const char webp[4] = {'R', 'I', 'F', 'F'};
    const char ico[4] = {0x00, 0x00, 0x01, 0x00};
    const char tif_ii[4] = {'I','I', 0x2A, 0x00};
    const char tif_mm[4] = {'M','M', 0x00, 0x2A};
    const char png[8] = {static_cast<char>(0x89), 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    const char jp2[12] = {0x00, 0x00, 0x00, 0x0c, 0x6a, 0x50, 0x20, 0x20, 0x0d, 0x0a, static_cast<char>(0x87), 0x0a};
    const char flac[4] = {0x66, 0x4C, 0x61, 0x43};
    const char mp3_1[3] = {0x49, 0x44, 0x33};
    const char mp3_2[2] = {static_cast<char>(0xFF), 0xF};
    
    
    
    if (!memcmp(bytes, bmp, 2)) {
        return "image/x-ms-bmp";
    } else if (!memcmp(bytes, gif, 3)) {
        return "image/gif";
    } else if (!memcmp(bytes, jpg, 3)) {
        return "image/jpeg";
    } else if (!memcmp(bytes, psd, 4)) {
        return "image/psd";
    } else if (!memcmp(bytes, iff, 4)) {
        return "image/iff";
    } else if (!memcmp(bytes, webp, 4)) {
        return "image/webp";
    } else if (!memcmp(bytes, ico, 4)) {
        return "image/vnd.microsoft.icon";
    } else if (!memcmp(bytes, tif_ii, 4) || !memcmp(bytes, tif_mm, 4)) {
        return "image/tiff";
    } else if (!memcmp(bytes, png, 8)) {
        return "image/png";
    } else if (!memcmp(bytes, jp2, 12)) {
        return "image/jp2";
    } else if (!memcmp(bytes, flac, 4)) {
        return "audio/x-flac";
    } else if (!memcmp(bytes, mp3_1, 3) || !memcmp(bytes, mp3_2, 2)) {
        return "audio/mpeg";
    }
    
    return "application/octet-stream"; // default type
    
}
 @end

 /**
  // see: http://id3.org/id3v2.4.0-frames
  const char *frameTranslation[][2] = {
  // Text information frames
  { "TALB", "ALBUM"},
  { "TBPM", "BPM" },
  { "TCOM", "COMPOSER" },
  { "TCON", "GENRE" },
  { "TCOP", "COPYRIGHT" },
  { "TDEN", "ENCODINGTIME" },
  { "TDLY", "PLAYLISTDELAY" },
  { "TDOR", "ORIGINALDATE" },
  { "TDRC", "DATE" },
  // { "TRDA", "DATE" }, // id3 v2.3, replaced by TDRC in v2.4
  // { "TDAT", "DATE" }, // id3 v2.3, replaced by TDRC in v2.4
  // { "TYER", "DATE" }, // id3 v2.3, replaced by TDRC in v2.4
  // { "TIME", "DATE" }, // id3 v2.3, replaced by TDRC in v2.4
  { "TDRL", "RELEASEDATE" },
  { "TDTG", "TAGGINGDATE" },
  { "TENC", "ENCODEDBY" },
  { "TEXT", "LYRICIST" },
  { "TFLT", "FILETYPE" },
  //{ "TIPL", "INVOLVEDPEOPLE" }, handled separately
  { "TIT1", "CONTENTGROUP" },
  { "TIT2", "TITLE"},
  { "TIT3", "SUBTITLE" },
  { "TKEY", "INITIALKEY" },
  { "TLAN", "LANGUAGE" },
  { "TLEN", "LENGTH" },
  //{ "TMCL", "MUSICIANCREDITS" }, handled separately
  { "TMED", "MEDIA" },
  { "TMOO", "MOOD" },
  { "TOAL", "ORIGINALALBUM" },
  { "TOFN", "ORIGINALFILENAME" },
  { "TOLY", "ORIGINALLYRICIST" },
  { "TOPE", "ORIGINALARTIST" },
  { "TOWN", "OWNER" },
  { "TPE1", "ARTIST"},
  { "TPE2", "ALBUMARTIST" }, // id3's spec says 'PERFORMER', but most programs use 'ALBUMARTIST'
  { "TPE3", "CONDUCTOR" },
  { "TPE4", "REMIXER" }, // could also be ARRANGER
  { "TPOS", "DISCNUMBER" },
  { "TPRO", "PRODUCEDNOTICE" },
  { "TPUB", "LABEL" },
  { "TRCK", "TRACKNUMBER" },
  { "TRSN", "RADIOSTATION" },
  { "TRSO", "RADIOSTATIONOWNER" },
  { "TSOA", "ALBUMSORT" },
  { "TSOP", "ARTISTSORT" },
  { "TSOT", "TITLESORT" },
  { "TSO2", "ALBUMARTISTSORT" }, // non-standard, used by iTunes
  { "TSRC", "ISRC" },
  { "TSSE", "ENCODING" },
  // URL frames
  { "WCOP", "COPYRIGHTURL" },
  { "WOAF", "FILEWEBPAGE" },
  { "WOAR", "ARTISTWEBPAGE" },
  { "WOAS", "AUDIOSOURCEWEBPAGE" },
  { "WORS", "RADIOSTATIONWEBPAGE" },
  { "WPAY", "PAYMENTWEBPAGE" },
  { "WPUB", "PUBLISHERWEBPAGE" },
  //{ "WXXX", "URL"}, handled specially
  // Other frames
  { "COMM", "COMMENT" },
  //{ "USLT", "LYRICS" }, handled specially
  // Apple iTunes proprietary frames
  { "PCST", "PODCAST" },
  { "TCAT", "PODCASTCATEGORY" },
  { "TDES", "PODCASTDESC" },
  { "TGID", "PODCASTID" },
  { "WFED", "PODCASTURL" },
  { "MVNM", "MOVEMENTNAME" },
  { "MVIN", "MOVEMENTNUMBER" },
  };
  **/
 
