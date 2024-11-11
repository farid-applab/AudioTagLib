//
//  TaglibWrapper.h
//  Taglib-iOS
//
//  Created by md farid on 2/11/24.
//

#import <Foundation/Foundation.h>
//#import <CoreAudio/CoreAudio.h>

@interface TaglibWrapper : NSObject

+ (nullable NSString *)getTitle:(NSString *)path;
+ (nullable NSString *)getComment:(NSString *)path;
+ (nullable NSMutableDictionary *)getMetadata:(NSString *)path;
+ (bool)setMetadata:(NSString *)path
         dictionary:(NSDictionary *)dictionary;

+ (bool)writeComment:(NSString *)path
             comment:(NSString *)comment;

+ (nullable NSArray *)getChapters:(NSString *)path;

+ (bool)setChapters:(NSString *)path
              array:(NSArray *)dictionary;

+ (nullable NSString *)detectFileType:(NSString *)path;
+ (nullable NSString *)detectStreamType:(NSString *)path;

// Declare printFileTags method
+ (void)printFileTags:(NSString *)path;

+ (nullable NSData *)getArtwork:(NSString *)path;
+ (bool)setArtwork:(NSString *)path
           artwork: (NSData *)artwork;
  

@end

