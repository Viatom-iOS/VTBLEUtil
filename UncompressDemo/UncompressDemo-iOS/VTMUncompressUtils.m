//
//  VTMUncompressUtils.m
//  UncompressDemo-iOS
//
//  Created by anwu on 2024/8/9.
//

#import "VTMUncompressUtils.h"
#import "VTMFileManager.h"

@implementation VTMUncompressUtils

+ (BOOL)uncompressER3WithResource:(NSString *)name andLead:(VTER3ShowLead)lead {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *finderPath = [VTMFileManager getTempFolderWithComponent:UncompressDataFolder];
    NSString *storeFileName = [VTMUncompressUtils storeDataNameWithFimeName:name andLead:lead];
    NSString *finalPath = [finderPath stringByAppendingPathComponent:storeFileName];
    
    BOOL needUnCompress = YES;
    BOOL result = NO;
    
    // file exists
    if ([fileManager fileExistsAtPath:finderPath] && [fileManager fileExistsAtPath:finalPath]) {
        // open file
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:finalPath];
        // file size
        unsigned long long fileSize = [fileHandle seekToEndOfFile];
        unsigned long long headSize = sizeof(VTERFileHead);
        unsigned long long tailSize = sizeof(VTERFileTail);
        // file length
        if (fileSize > headSize + tailSize) {
            // file tail
            VTERFileTail tail = {0x00};
            unsigned long long offset = fileSize - tailSize;
            [fileHandle seekToFileOffset:offset];
            NSData *tailData = [fileHandle readDataToEndOfFile];
            [tailData getBytes:&tail range:NSMakeRange(0, sizeof(VTERFileTail))];
            
            if (tail.magic == 0xA55A0438) {
                needUnCompress = NO;
            }
        }
        // close file
        [fileHandle closeFile];
    }
    // need uncompress
    if (needUnCompress) {
        // delete all lead data
        for (NSNumber *lead in [VTBLEParser leadTypesWithCable:VTER3Cable_LEAD_10]) {
            NSString *leadStoreFileName = [VTMUncompressUtils storeDataNameWithFimeName:name andLead:[lead integerValue]];
            [VTMFileManager deleteUncompressDataFileWithFileName:leadStoreFileName];
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        NSData *originalData = [NSData dataWithContentsOfFile:path];
        NSLog(@"ER3 start");
        __block VTER3Cable cable = VTER3Cable_LEAD_Unidentified;
        __weak typeof(self) weakSelf = self;
        [VTBLEParser parseER3OriginFile:originalData head:^(VTERFileHead head) {
            cable = head.cable_type;
            NSData *headData = [NSData dataWithBytes:&head length:sizeof(VTERFileHead)];
            [weakSelf saveER3UncompressHeadData:headData withName:name andCable:cable];
        } leadFragments:^(NSArray<NSData *> * _Nonnull leadDatas) {
            [weakSelf saveER3UncompressLeadDatas:leadDatas withName:name];
        } tail:^(VTERFileTail tail) {
            NSData *tailData = [NSData dataWithBytes:&tail length:sizeof(VTERFileTail)];
            [weakSelf saveER3UncompressTailData:tailData withName:name andCable:cable];
        }];
        NSLog(@"ER3 end ");
        result = YES;
    } else {
        NSLog(@"No need to decompress again");
        result = YES;
    }
    return result;
}

/// save head data
+ (void)saveER3UncompressHeadData:(NSData *)headData withName:(NSString *)name andCable:(VTER3Cable)cable {
    NSArray<NSNumber *> *types = [VTBLEParser leadTypesWithCable:cable];
    for (NSNumber *number in types) {
        NSString *storeName = [VTMUncompressUtils storeDataNameWithFimeName:name andLead:[number integerValue]];
        [VTMFileManager writeUncompressDataToSandbox:headData fileName:storeName];
    }
}

/// save lead fragments data
+ (void)saveER3UncompressLeadDatas:(NSArray<NSData *> *)leadDatas withName:(NSString *)name {
    for (NSUInteger i = 0; i < leadDatas.count; i ++) {
        NSString *storeName = [VTMUncompressUtils storeDataNameWithFimeName:name andLead:i];
        [VTMFileManager writeUncompressDataToSandbox:leadDatas[i] fileName:storeName];
    }
}

/// save tail data
+ (void)saveER3UncompressTailData:(NSData *)tailData withName:(NSString *)name andCable:(VTER3Cable)cable {
    NSArray<NSNumber *> *types = [VTBLEParser leadTypesWithCable:cable];
    for (NSNumber *number in types) {
        NSString *storeName = [VTMUncompressUtils storeDataNameWithFimeName:name andLead:[number integerValue]];
        [VTMFileManager writeUncompressDataToSandbox:tailData fileName:storeName];
    }
}

/// store name
+ (NSString *)storeDataNameWithFimeName:(NSString *)name andLead:(VTER3ShowLead)lead {
    NSString *leadName = [VTBLEParser leadTitlesWithCable:VTER3Cable_LEAD_10][lead];
    return [NSString stringWithFormat:@"%@_%@.dat", name, leadName];
}

+ (BOOL)uncompressER1WithResource:(NSString *)name {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *finderPath = [VTMFileManager getTempFolderWithComponent:UncompressDataFolder];
    NSString *storeFileName = [NSString stringWithFormat:@"%@.dat", name];
    NSString *finalPath = [finderPath stringByAppendingPathComponent:storeFileName];
    
    BOOL needUnCompress = YES;
    BOOL result = NO;
    
    // file exists
    if ([fileManager fileExistsAtPath:finderPath] && [fileManager fileExistsAtPath:finalPath]) {
        // open file
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:finalPath];
        // file size
        unsigned long long fileSize = [fileHandle seekToEndOfFile];
        unsigned long long headSize = sizeof(VTERFileHead);
        unsigned long long tailSize = sizeof(VTERFileTail);
        // file length
        if (fileSize > headSize + tailSize) {
            // file tail
            VTERFileTail tail = {0x00};
            unsigned long long offset = fileSize - tailSize;
            [fileHandle seekToFileOffset:offset];
            NSData *tailData = [fileHandle readDataToEndOfFile];
            [tailData getBytes:&tail range:NSMakeRange(0, sizeof(VTERFileTail))];
            
            if (tail.magic == 0xA55A0438) {
                needUnCompress = NO;
            }
        }
        // close file
        [fileHandle closeFile];
    }
    
    // need uncompress
    if (needUnCompress) {
        // delete all lead data
        [VTMFileManager deleteUncompressDataFileWithFileName:storeFileName];
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        NSData *originalData = [NSData dataWithContentsOfFile:path];
        NSLog(@"ER1 start");
        [VTBLEParser parseER1OriginFile:originalData head:^(VTERFileHead head) {
            NSData *headData = [NSData dataWithBytes:&head length:sizeof(VTERFileHead)];
            [VTMFileManager writeUncompressDataToSandbox:headData fileName:storeFileName];
        } fragment:^(NSData * _Nonnull fragmentData) {
            [VTMFileManager writeUncompressDataToSandbox:fragmentData fileName:storeFileName];
        } tail:^(VTERFileTail tail) {
            NSData *tailData = [NSData dataWithBytes:&tail length:sizeof(VTERFileTail)];
            [VTMFileManager writeUncompressDataToSandbox:tailData fileName:storeFileName];
        }];
        NSLog(@"ER1 end ");
        result = YES;
    } else {
        NSLog(@"No need to decompress again");
        result = YES;
    }
    return result;
}

/// uncompress Data
+ (NSData *)er3DataWithResource:(NSString *)name andLead:(VTER3ShowLead)lead {
    NSString *finderPath = [VTMFileManager getTempFolderWithComponent:UncompressDataFolder];
    NSString *storeFileName = [VTMUncompressUtils storeDataNameWithFimeName:name andLead:lead];
    NSString *finalPath = [finderPath stringByAppendingPathComponent:storeFileName];
    return [NSData dataWithContentsOfFile:finalPath];
}

+ (NSData *)er1DataWithResource:(NSString *)name {
    NSString *finderPath = [VTMFileManager getTempFolderWithComponent:UncompressDataFolder];
    NSString *storeFileName = [NSString stringWithFormat:@"%@.dat", name];
    NSString *finalPath = [finderPath stringByAppendingPathComponent:storeFileName];
    return [NSData dataWithContentsOfFile:finalPath];
}

@end
