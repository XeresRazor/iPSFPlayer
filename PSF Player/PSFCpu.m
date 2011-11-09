//
//  PSFCpu.m
//  PSF Player
//
//  Created by Andrew Paradise on 10/27/11.
//  Copyright (c) 2011 Digital Worlds Entertainment. All rights reserved.
//

#import "PSFCpu.h"
#import "PSFUtils.h"

@implementation PSFCpu
@synthesize executableData = _executableData;
@synthesize memory = _memory;

-(id)initWithExeData:(NSData *)data {
    self = [super init];
    if (self) {
        self.executableData = data;
        //Load the executable into memory and setup the initial CPU state
        //First allocate ram
        self.memory = [[NSMutableData alloc] initWithLength:1024*1024*2]; //Allocate 2MB of ram
        //Parse out the exe and get the data we need into memory
        NSLog(@"Executable file has size:0x%X",[self.executableData length]);
        [self.executableData getBytes:&pc range:NSMakeRange(0x10, 4)];
        NSLog(@"Initial PC:0x%X",pc);
		npc = pc + 4;
        
        uint32_t textStart;
        uint32_t textSize;
        [self.executableData getBytes:&textStart range:NSMakeRange(0x18, 4)];
        NSLog(@"Text start:0x%X",textStart);
        [self.executableData getBytes:&textSize range:NSMakeRange(0x1C, 4)];
        NSLog(@"Text size:0x%X",textSize);
        [self.executableData getBytes:&cpuRegisters.regs.sp range:NSMakeRange(0x30, 4)];
        NSLog(@"Initial SP:0x%X",cpuRegisters.regs.sp);
        //Copy the text data from the executable file, in to memory
        NSData *programData = [self.executableData subdataWithRange:NSMakeRange(0x800, textSize)];
        NSLog(@"EXE text section size:0x%X",[programData length]);
        [self.memory replaceBytesInRange:NSMakeRange(mem(textStart), textSize) withBytes:[programData bytes]];
        //Show the first instruction
        //[self.memory getBytes:&instruction range:NSMakeRange(mem(pc), 4)];
        //NSLog(@"Fetched Next instruction:0x%X with OpCode:0x%02X from address:0x%X",instruction, currOp, pc);
        //NSLog(@"Next Op Name:%@",opNames[currOp]);
        
    }
    return self;
}

-(BOOL)executeInstruction {
	BOOL shouldRun = YES;
	cpuRegisters.regs.zr = 0;
    //currInstruction = instruction;
	int32_t offset;
	offset = 4;
    //pc+=4; //point to the next instruction word
    [self.memory getBytes:&currInstruction range:NSMakeRange(mem(pc), 4)];
    
    //NSLog(@"Fetched instruction:0x%X with OpCode:0x%02X from address:0x%X",currInstruction, currOp, pc - 4);
   // NSLog(@"Op Name:%@",opNames[currOp]);
    switch (currOp) {
        case op_SPECIAL:
            //Special
            //NSLog(@"Executing Special - With Function:0x%02X",currFunct);
			[PSFUtils logROperand:currInstruction fromAddress:pc registers:cpuRegisters];
            switch (currFunct) {
				case func_SLL:
					//Shift Left Logical
					//NSLog(@"Executing Shift Left Logical - Setting Register:0x%02X to register:0x%02X shifted left:%d",currRd, currRt, currShamt);
					cpuRegisters.indexedRegs[currRd] = cpuRegisters.indexedRegs[currRt] << currShamt;
					break;
				case func_SRL:
					//Shift Right Logical
					cpuRegisters.indexedRegs[currRd] = cpuRegisters.indexedRegs[currRt] >> currShamt;
					break;
				case func_SUBU:
					//Subtract Unsigned
					cpuRegisters.indexedRegs[currRd] =cpuRegisters.indexedRegs[currRs] - cpuRegisters.indexedRegs[currRt];
					break;
				case func_OR:
					//Logical Or
					cpuRegisters.indexedRegs[currRd] =cpuRegisters.indexedRegs[currRs] | cpuRegisters.indexedRegs[currRt];
					break;
				case func_SLTU:
					//Set on Less Than Unsigned
					//NSLog(@"Executing Set on Less Than Unsigned - Setting Register:0x%02X if register 0x%02X < 0x%02X",currRd, currRs, currRt);
					cpuRegisters.indexedRegs[currRd] = cpuRegisters.indexedRegs[currRs] < cpuRegisters.indexedRegs[currRt] ? 1 : 0;
					break;
                default:
                    NSLog(@"Special Function:%@ is not yet implemented or invalid", funcNames[currFunct]);
					shouldRun = NO;
                    break;
            }
            break;
		case op_BNE:
			//Branch on Not Equal
			//NSLog(@"Executing Branch on Not Equal - Branching to offset:%d if register:0x%02X is not equal to register:0x%02X - Delay Slot PC:0x%X",((int32_t)((int32_t)currImm) << 2), currRs, currRt, pc);
			[PSFUtils logIOperand:currInstruction fromAddress:pc registers:cpuRegisters];
			int16_t immediate = (int16_t)currImm;
			int32_t newOffset = ((int32_t)immediate) << 2;
			offset = cpuRegisters.indexedRegs[currRs] == cpuRegisters.indexedRegs[currRt] ? 4 : newOffset;//((int32_t)((int16_t)currImm) << 2);
			NSLog(@"New PC:0x%X",npc + offset);
			break;
		case op_ADDI:
			//Add Immediate Unsigned
            [PSFUtils logIOperand:currInstruction fromAddress:pc registers:cpuRegisters];
			cpuRegisters.indexedRegs[currRt] = cpuRegisters.indexedRegs[currRs]  + currImm;
            break;
        case op_ADDIU:
            //Add Immediate Unsigned
            //NSLog(@"Executing Add Immediate Unsigned - Adding immediate:0x%04X to register:%d and writing to register:%d", currImm, currRs, currRt);
            [PSFUtils logIOperand:currInstruction fromAddress:pc registers:cpuRegisters];
			cpuRegisters.indexedRegs[currRt] = cpuRegisters.indexedRegs[currRs]  + currImm;
            break;
        case op_LUI:
            //Load upper immediate
            //NSLog(@"Executing Load Upper Immediate - Loading immediate:0x%04X to register %d",currImm, currRt);
            [PSFUtils logIOperand:currInstruction fromAddress:pc registers:cpuRegisters];
			cpuRegisters.indexedRegs[currRt] = currImm << 16;
            break;
		case op_LW:
			//Load Word
			[PSFUtils logIOperand:currInstruction fromAddress:pc registers:cpuRegisters];
			[self.memory getBytes:&cpuRegisters.indexedRegs[currRt] range:NSMakeRange(mem(currRs + (int16_t)currImm), 4)];
			break;
        case op_SW:
            //Store Word
            //NSLog(@"Executing Store Word - Loading value:0x%X from register %d, to memory location %X",cpuRegisters.indexedRegs[currRt], currRt, mem(currRs + (uint16_t)currImm));
            [PSFUtils logIOperand:currInstruction fromAddress:pc registers:cpuRegisters];
			[self.memory replaceBytesInRange:NSMakeRange(mem(currRs + (int16_t)currImm), 4) withBytes:&cpuRegisters.indexedRegs[currRt]];
            break;
        default:
            NSLog(@"Unable to execute op:\"%@\"",opNames[currOp]);
            shouldRun = NO;
            break;
    }
	pc = npc;
	npc += offset;
	return  shouldRun;
}

@end
