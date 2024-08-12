//
//  VTBLEEnum.h
//  VTBLEUtils
//
//  Created by anwu on 2024/8/8.
//

#ifndef VTBLEEnum_h
#define VTBLEEnum_h

/// ER3线缆类型
typedef enum : u_char {
    VTER3Cable_LEAD_10 = 0x00,       // 10导            8通道
    VTER3Cable_LEAD_6 = 0x01,        // 6导             4通道
    VTER3Cable_LEAD_5 = 0x02,        // 5导             4通道
    VTER3Cable_LEAD_3 = 0x03,        // 3导             4通道
    VTER3Cable_LEAD_3_TEMP = 0x04,   // 3导 带体温       4通道
    VTER3Cable_LEAD_4_LEG = 0x05,    // 4导 带胸贴       4通道
    VTER3Cable_LEAD_5_LEG = 0x06,    // 5导 带胸贴       4通道
    VTER3Cable_LEAD_6_LEG = 0x07,    // 6导 带胸贴       4通道
    VTER3Cable_LEAD_Unidentified = 0xff,// 未识别的导联线
} VTER3Cable;

/// ER3显示导联
typedef NS_ENUM(NSUInteger, VTER3ShowLead) {
    VTER3ShowLead_I = 0,
    VTER3ShowLead_II,
    VTER3ShowLead_III,
    VTER3ShowLead_aVR,
    VTER3ShowLead_aVL,
    VTER3ShowLead_aVF,
    VTER3ShowLead_V1,
    VTER3ShowLead_V2,
    VTER3ShowLead_V3,
    VTER3ShowLead_V4,
    VTER3ShowLead_V5,
    VTER3ShowLead_V6,
};

#endif /* VTBLEEnum_h */
