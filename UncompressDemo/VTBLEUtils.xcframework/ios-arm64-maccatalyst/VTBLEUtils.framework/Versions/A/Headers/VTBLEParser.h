//
//  VTBLEParser.h
//  VTBLEUtils
//
//  Created by anwu on 2024/8/8.
//

#import <Foundation/Foundation.h>
#import "VTBLEStruct.h"
#import "VTBLEEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface VTBLEParser : NSObject

/// ER1 uncompress original data
/// - Parameters:
///   - fileData: original data
///   - headBlock: head
///   - fragmentBlock: fragment data
///   - tailBlock: tail
+ (void)parseER1OriginFile:(NSData *)fileData head:(void(^)(VTERFileHead head))headBlock fragment:(void(^)(NSData *fragmentData))fragmentBlock tail:(void(^)(VTERFileTail tail))tailBlock;

/// ER3 uncompress original data
/// - Parameters:
///   - fileData: original data
///   - headBlock: head
///   - leadFragments: 12 leads of data，
///   - tailBlock: tail
+ (void)parseER3OriginFile:(NSData *)fileData head:(void(^)(VTERFileHead head))headBlock leadFragments:(void(^)(NSArray<NSData *> *leadDatas))leadFragments tail:(void(^)(VTERFileTail tail))tailBlock;

/// lead titles
/// - Parameter cable: cable type
+ (NSArray<NSString *> *)leadTitlesWithCable:(VTER3Cable)cable;

/// lead types
/// - Parameter cable: cable type
+ (NSArray<NSNumber *> *)leadTypesWithCable:(VTER3Cable)cable;

/// short -> mv
+ (float)mVFromShort:(short)n;

/// short -> mv
+ (float)er3MvFromShort:(short)n;

@end

NS_ASSUME_NONNULL_END
