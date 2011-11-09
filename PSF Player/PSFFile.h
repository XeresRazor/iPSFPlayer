//
//  PSFFile.h
//  PSF Player
//
//  Created by David Green on 10/22/11.
//  Copyright (c) 2011 Digital Worlds Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

//Offsets and sizes of fixed items in the psf file
#define PSFSignatureOffset 0
#define PSFReservedSizeOffset 4
#define PSFCompressedProgramSizeOffset 8
#define PSFCompressedProgramCRCOffset 12
#define PSFReservedDataStartOffset 16


//Custom data types
#pragma pack(push,1)
typedef union {
    struct {
        
        char sig0;
        char sig1;
        char sig2;
        uint8_t version;
    } headerValues;
    uint32_t headerWord;
}PSFHeader;
#pragma pack(pop)



@interface PSFFile : NSObject
{
    //Data Information
    uint32_t reservedSize;
    uint32_t compressedProgramSize;
    uint32_t compressedCRC32;
    uint8_t *reservedData;
    uint8_t *compressedProgramData;
    char *tagData;
    NSData *_programData;
}
@property (nonatomic, copy) NSString *psfPath;
@property (nonatomic, retain) NSData *fileData;
@property (nonatomic, readonly) NSData *programData;
@property (nonatomic, retain) NSMutableDictionary *tags;

//standard tags
@property (nonatomic, retain) NSString *tagTitle;
@property (nonatomic, retain) NSString *tagArtist;
@property (nonatomic, retain) NSString *tagGame;
@property (nonatomic, retain) NSString *tagYear;
@property (nonatomic, retain) NSString *tagGenre;
@property (nonatomic, retain) NSString *tagComment;
@property (nonatomic, retain) NSString *tagCopyright;
@property (nonatomic, retain) NSString *tagPSFBy;
@property (nonatomic, retain) NSNumber *volume;
@property (nonatomic, retain) NSString *lengthString;
@property (nonatomic, retain) NSString *fadeString;


-(id)initWithFilePath:(NSString *)path;
@end
