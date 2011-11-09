//
//  PSFCpu.h
//  PSF Player
//
//  Created by Andrew Paradise on 10/27/11.
//  Copyright (c) 2011 Digital Worlds Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSFUtils;

//Macros to quickly get parts of the instruction
#define mem(x) (x & 0x001FFFFF)
#define currOp ((currInstruction >> 26) & 0x3F)
#define currRs ((currInstruction >> 21) & 0x1F)
#define currRt ((currInstruction >> 16) & 0x1F)
#define currRd ((currInstruction >> 11) & 0x1F)
#define currShamt ((currInstruction >> 6) & 0x1F)
#define currFunct (currInstruction & 0x3F)
#define currImm (currInstruction & 0xFFFF)
#define currAdd (currInstruction & 0x03FFFFFF)

enum ops {
    op_SPECIAL = 0,
    op_BCOND,
    op_J,
    op_JAL,
    op_BEQ,
    op_BNE,
    op_BLEZ,
    op_BGTZ,
    op_ADDI,
    op_ADDIU,
    op_SLTI,
    op_SLTIU,
    op_ANDI,
    op_ORI,
    op_XORI,
    op_LUI,
    op_COP0,
    op_COP1,
    op_COP2,
    op_COP3,
    op_NULL14,
    op_NULL15,
    op_NULL16,
    op_NULL17,
    op_NULL18,
    op_NULL19,
    op_NULL1A,
    op_NULL1B,
    op_NULL1C,
    op_NULL1D,
    op_NULL1E,
    op_NULL1F,
    op_LB,
    op_LH,
    op_LWL,
    op_LW,
    op_LBU,
    op_LHU,
    op_LWR,
    op_NULL27,
    op_SB,
    op_SH,
    op_SWL,
    op_SW,
    op_NULL2C,
    op_NULL2D,
    op_SWR,
    op_NULL2F,
    op_LWC0,
    op_LWC1,
    op_LWC2,
    op_LWC3,
    op_NULL34,
    op_NULL35,
    op_NULL36,
    op_NULL37,
    op_SWC0,
    op_SWC1,
    op_SWC2,
    op_SWC3,
    op_NULL3C,
    op_NULL3D,
    op_NULL3E,
    op_NULL3F
};

enum funcs {
	func_SLL,
	func_NULL01,
	func_SRL,
	func_SRA,
	func_SLLV,
	func_NULL05,
	func_SRLV,
	func_SRAV,
	func_JR,
	func_JALR,
	func_NULL0A,
	func_NULL0B,
	func_SYSCALL,
	func_BREAK,
	func_NULL0E,
	func_NULL0F,
	func_MFHI,
	func_MTHI,
	func_MFLO,
	func_MTLO,
	func_NULL14,
	func_NULL15,
	func_NULL16,
	func_NULL17,
	func_MULT,
	func_MULTU,
	func_DIV,
	func_DIVU,
	func_NULL1C,
	func_NULL1D,
	func_NULL1E,
	func_NULL1F,
	func_ADD,
	func_ADDU,
	func_SUB,
	func_SUBU,
	func_AND,
	func_OR,
	func_XOR,
	func_NOR,
	func_NULL28,
	func_NULL29,
	func_SLT,
	func_SLTU,
	func_NULL2C,
	func_NULL2D,
	func_NULL2E,
	func_NULL2F,
	func_NULL30,
	func_NULL31,
	func_NULL32,
	func_NULL33,
	func_NULL34,
	func_NULL35,
	func_NULL36,
	func_NULL37,
	func_NULL38,
	func_NULL39,
	func_NULL3A,
	func_NULL3B,
	func_NULL3C,
	func_NULL3D,
	func_NULL3E,
	func_NULL3F
};

static NSString *opNames[] = {
    @"Special",
    @"BCOND",
    @"J",
    @"JAL",
    @"BEQ",
    @"BNE",
    @"BLEZ",
    @"BGTZ",
    @"ADDI",
    @"ADDIU",
    @"SLTI",
    @"SLTIU",
    @"ANDI",
    @"ORI",
    @"XORI",
    @"LUI",
    @"COP0",
    @"COP1",
    @"COP2",
    @"COP3",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL",
    @"LB",
    @"LH",
    @"LWL",
    @"LW",
    @"LBU",
    @"LHU",
    @"LWR",
    @"NULL",
    @"SB",
    @"SH",
    @"SWL",
    @"SW",
    @"NULL",
    @"NULL",
    @"SWR",
    @"NULL",
    @"LWC0",
    @"LWC1",
    @"LWC2",
    @"LWC3",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL",
    @"SWC0",
    @"SWC1",
    @"SWC2",
    @"SWC3",
    @"NULL",
    @"NULL",
    @"NULL",
    @"NULL"
};

static NSString *funcNames[] = {
	@"SLL",
	@"NULL01",
	@"SRL",
	@"SRA",
	@"SLLV",
	@"NULL05",
	@"SRLV",
	@"SRAV",
	@"JR",
	@"JALR",
	@"NULL0A",
	@"NULL0B",
	@"SYSCALL",
	@"BREAK",
	@"NULL0E",
	@"NULL0F",
	@"MFHI",
	@"MTHI",
	@"MFLO",
	@"MTLO",
	@"NULL14",
	@"NULL15",
	@"NULL16",
	@"NULL17",
	@"MULT",
	@"MULTU",
	@"DIV",
	@"DIVU",
	@"NULL1C",
	@"NULL1D",
	@"NULL1E",
	@"NULL1F",
	@"ADD",
	@"ADDU",
	@"SUB",
	@"SUBU",
	@"AND",
	@"OR",
	@"XOR",
	@"NOR",
	@"NULL28",
	@"NULL29",
	@"SLT",
	@"SLTU",
	@"NULL2C",
	@"NULL2D",
	@"NULL2E",
	@"NULL2F",
	@"NULL30",
	@"NULL31",
	@"NULL32",
	@"NULL33",
	@"NULL34",
	@"NULL35",
	@"NULL36",
	@"NULL37",
	@"NULL38",
	@"NULL39",
	@"NULL3A",
	@"NULL3B",
	@"NULL3C",
	@"NULL3D",
	@"NULL3E",
	@"NULL3F"
};

typedef union {
    struct {
        uint32_t zr, at, //Constant Zero, Reserved for assembler
        v0, v1, // Values for results and expression evaluation
        a0, a1, a2, a3, //Arguments
        t0, t1, t2, t3, t4, t5, t6, t7, //Temporaries
        s0, s1, s2, s3, s4, s5, s6, s7, //Saved (preserved across calls)
        t8, t9, // More temps
        k0, k1, //Reserved for Kernel
        gp, sp, fp, ra, //Global, Stack, and Frame Pointers. Return address
        lo, hi; //multiplication and division bits
    } regs;
    uint32_t indexedRegs[34]; //Lo and Hi are in [33] and [34]
} PSXRegisters;

@interface PSFCpu : NSObject {
    PSXRegisters cpuRegisters;
    uint32_t pc;
	uint32_t npc;
    //uint32_t instruction; //The instruction that's fetched at the beginning of a clock tick, will be executed next clock
    uint32_t currInstruction; //The instruction that is being executed during the current tick
    uint32_t cycle;
    uint32_t interrupt;
    
}
//Properties
@property (nonatomic, retain) NSData *executableData;
@property (nonatomic, retain) NSMutableData *memory;

//Methods

-(id)initWithExeData:(NSData *)data;
-(BOOL)executeInstruction;
@end
