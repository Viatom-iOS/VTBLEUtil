//
//  VTMFileManager.m
//  UncompressDemo-iOS
//
//  Created by anwu on 2024/8/9.
//

#import "VTMFileManager.h"

@implementation VTMFileManager

+ (NSString *)getTempFolderWithComponent:(NSString *)component {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:component];
}

+ (void)writeUncompressDataToSandbox:(NSData *)data fileName:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *finderPath = [self getTempFolderWithComponent:UncompressDataFolder];
    if (![fileManager fileExistsAtPath:finderPath]){
        [fileManager createDirectoryAtPath:finderPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *finalPath = [finderPath stringByAppendingPathComponent:fileName];
    if (![fileManager fileExistsAtPath:finalPath]){
        [fileManager createFileAtPath:finalPath contents:nil attributes:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:finalPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}

+ (BOOL)deleteUncompressDataFileWithFileName:(NSString *)fileName {
    if (!fileName.length) {
        return YES;
    }
    NSString *finderPath = [self getTempFolderWithComponent:UncompressDataFolder];
    NSString *finalPath = [finderPath stringByAppendingPathComponent:fileName];
    return [[NSFileManager defaultManager] removeItemAtPath:finalPath error:nil];
}

@end
