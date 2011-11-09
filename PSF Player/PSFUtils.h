//
//  PSFUtils.h
//  PSF Player
//
//  Created by David Green on 11/8/11.
//  Copyright (c) 2011 Digital Worlds Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSFCpu.h"

#define Op(x) ((x >> 26) & 0x3F)
#define Rs(x) ((x >> 21) & 0x1F)
#define Rt(x) ((x >> 16) & 0x1F)
#define Rd(x) ((x >> 11) & 0x1F)
#define Shamt(x) ((x >> 6) & 0x1F)
#define Funct(x) (x & 0x3F)
#define Imm(x) (x & 0xFFFF)
#define Add(x) (x & 0x03FFFFFF)


@interface PSFUtils : NSObject
+(void)logJOperand:(uint32_t)operand fromAddress:(uint32_t)address registers:(PSXRegisters)registers;
+(void)logROperand:(uint32_t)operand fromAddress:(uint32_t)address registers:(PSXRegisters)registers;
+(void)logIOperand:(uint32_t)operand fromAddress:(uint32_t)address registers:(PSXRegisters)registers;
@end
