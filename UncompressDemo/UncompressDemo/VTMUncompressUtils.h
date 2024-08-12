//
//  VTMUncompressUtils.h
//  UncompressDemo
//
//  Created by anwu on 2024/8/7.
//

#import <Foundation/Foundation.h>
#import <VTBLEUtils/VTBLEUtils.h>

NS_ASSUME_NONNULL_BEGIN

@interface VTMUncompressUtils : NSObject

+ (BOOL)uncompressER3WithResource:(NSString *)name andLead:(VTER3ShowLead)lead;

+ (BOOL)uncompressER1WithResource:(NSString *)name;

/// er3 data
+ (NSData *)er3DataWithResource:(NSString *)name andLead:(VTER3ShowLead)lead;

/// er1 data
+ (NSData *)er1DataWithResource:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
