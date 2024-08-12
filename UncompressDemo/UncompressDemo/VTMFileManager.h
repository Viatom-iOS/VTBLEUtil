//
//  VTMFileManager.h
//  UncompressDemo
//
//  Created by anwu on 2024/8/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define UncompressDataFolder @"UncompressData"  // a folder name

@interface VTMFileManager : NSObject

//***************************** Uncompress *************************************/

/// Get the path to the component folder in the Temp file
+ (NSString *)getTempFolderWithComponent:(NSString *)component;

/// Write the uncompress data
+ (void)writeUncompressDataToSandbox:(NSData *)data fileName:(NSString *)fileName;

/// Delete the uncompress data
+ (BOOL)deleteUncompressDataFileWithFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
