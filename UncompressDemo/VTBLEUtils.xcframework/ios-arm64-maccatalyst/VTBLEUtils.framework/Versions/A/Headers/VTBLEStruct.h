//
//  VTBLEStruct.h
//  VTBLEUtils
//
//  Created by anwu on 2024/8/8.
//

#ifndef VTBLEStruct_h
#define VTBLEStruct_h

#include <CoreGraphics/CGBase.h>
#pragma pack(1)

/// @brief file tail of er3. EqulTo FileHead_t of er3.
typedef struct {
    u_char file_version;    ///< 文件版本 e.g.  0x01 :  V1
    u_char type;            ///< 文件类型 数据文件：固定为0x04
    u_char cable_type;      ///< 线缆类型 数据文件：无效数据    波形文件：线缆类型
    u_char reserved[7];     ///< 预留
} CG_BOXABLE VTERFileHead;

/// @brief file tail of er3. EqulTo FileTail_t of er3.
typedef struct {
    u_int recoring_time;    ///< 记录时长，e.g 3600: 3600s
    u_short data_crc;       ///< 文件头部+原始波形和校验
    u_char reserved[10];    ///< 预留
    u_int magic;            ///< 文件标识 固定值为 0xA55A0438
} CG_BOXABLE VTERFileTail;

#pragma pack()

#endif /* VTBLEStruct_h */
