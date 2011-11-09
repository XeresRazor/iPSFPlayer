//
//  PSFUtils.m
//  PSF Player
//
//  Created by David Green on 11/8/11.
//  Copyright (c) 2011 Digital Worlds Entertainment. All rights reserved.
//

#import "PSFUtils.h"
static BOOL logJ = YES;
static BOOL logR = YES;
static BOOL logI = YES;

@implementation PSFUtils

+(void)logJOperand:(uint32_t)operand fromAddress:(uint32_t)address registers:(PSXRegisters)registers {
	if (logJ) {
		printf("\nAddress:0x%08X - OpCode:%8s(0x%02X)\nJump target:0x%08X\n", 
			   address,
			   [opNames[Op(operand)] cStringUsingEncoding:NSUTF8StringEncoding],
			   Op(operand),
			   (Add(operand) << 2) | (address & 0xF0000000));
	}
}

+(void)logROperand:(uint32_t)operand fromAddress:(uint32_t)address registers:(PSXRegisters)registers {
	if (logR) {
		printf("\nAddress:0x%08X - OpCode:%8s(0x%02X)\nSource:%02d(0x%08X) - Target:%02d(0x%08X) - Destination:%02d(0x%08X)\nShift:%02d - Function:%8s(0x%02X)\n",
			   address, 
			   [opNames[Op(operand)] cStringUsingEncoding:NSUTF8StringEncoding],
			   Op(operand), 
			   Rs(operand),
			   registers.indexedRegs[Rs(operand)],
			   Rt(operand),
			   registers.indexedRegs[Rt(operand)],
			   Rd(operand), 
			   registers.indexedRegs[Rd(operand)],
			   Shamt(operand), 
			   [funcNames[Funct(operand)] cStringUsingEncoding:NSUTF8StringEncoding], 
			   Funct(operand));
	}
}

+(void)logIOperand:(uint32_t)operand fromAddress:(uint32_t)address registers:(PSXRegisters)registers {
	if (logI) {
		printf("\nAddress:0x%08X - OpCode:%8s(0x%02X)\nSource:%02d(0x%08X) - Target:%02d(0x%08X)\nImmediate:0x%04X\n",
			   address, 
			   [opNames[Op(operand)] cStringUsingEncoding:NSUTF8StringEncoding],
			   Op(operand), 
			   Rs(operand),
			   registers.indexedRegs[Rs(operand)],
			   Rt(operand),
			   registers.indexedRegs[Rt(operand)],
			   Imm(operand));
	}
}

@end
