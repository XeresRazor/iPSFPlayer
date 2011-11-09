//
//  PSFFile.m
//  PSF Player
//
//  Created by David Green on 10/22/11.
//  Copyright (c) 2011 Digital Worlds Entertainment. All rights reserved.
//

#import "PSFFile.h"
#import <zlib.h>

@interface PSFFile ()
-(BOOL)verifyFileData;
@end

@implementation PSFFile
@synthesize psfPath = _psfPath;
@synthesize fileData = _fileData;
@synthesize programData = _programData;
@synthesize tags = _tags;

//Tags
@synthesize tagArtist;
@synthesize tagComment;
@synthesize tagCopyright;
@synthesize tagGame;
@synthesize tagGenre;
@synthesize tagPSFBy;
@synthesize tagTitle;
@synthesize tagYear;
@synthesize volume;
@synthesize lengthString;
@synthesize fadeString;


-(id)initWithFilePath:(NSString *)path {
	self = [super init];
	if (self) {
		//Do Setup
		self.psfPath = path;
		NSError *error = nil;
		self.fileData = [[NSData alloc] initWithContentsOfFile:self.psfPath options:NSDataReadingMappedIfSafe error:&error];
		if (error) {
			NSLog(@"Error loading file: %@",[error localizedDescription]);
		}
		if (![self verifyFileData]) {
			NSLog(@"File could not be verified as a PSF file.");
		}
		//File has been loaded, header values parsed out, and tags pulled out of the file
        //Now we decompress the executable code
        uLongf uncompressedSize = 1024*1024*2;
        Bytef *uncompressedProgram = malloc(sizeof(Bytef) * uncompressedSize); //PSX only has 2MB of memory, program should not be larger than that
        
        int success = uncompress(uncompressedProgram, &uncompressedSize, compressedProgramData, compressedProgramSize);
        if (success != Z_OK) {
            switch (success) {
                case Z_MEM_ERROR:
                    NSLog(@"Failed expanding the psx executable due to a memory error");
                    break;
                case Z_BUF_ERROR:
                    NSLog(@"Failed expanding the psx executable due to a memory error");
                    break;
                case Z_DATA_ERROR:
                    NSLog(@"Failed expanding the psx executable due to corrupted compressed data");
                default:
                    NSLog(@"Failed expanding the psx executable due to an unknown error:%X",success);
                    break;
            }
        }
        NSData *uncompressedFileData = [NSData dataWithBytes:uncompressedProgram length:uncompressedSize];
        NSString *saveProgramPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"extractedPSF.pxe"];
        [uncompressedFileData writeToFile:saveProgramPath atomically:YES];
        NSLog(@"Wrote executable of size %d to file:%@",(int)uncompressedSize, saveProgramPath);
        _programData = [uncompressedFileData copy];
        free(uncompressedProgram);
	}
    
	return self;
}

-(BOOL)verifyFileData {
    uint8_t *fileBytes = (uint8_t *)[self.fileData bytes];
	PSFHeader header = *(PSFHeader *)(fileBytes + PSFSignatureOffset);
    NSLog(@"Header:0x%X-'%c'-%X,'%c'-%X,'%c'-%X,%d-%X",header.headerWord, header.headerValues.sig0, header.headerValues.sig0, header.headerValues.sig1, header.headerValues.sig1, header.headerValues.sig2, header.headerValues.sig2, header.headerValues.version, header.headerValues.version);
	if (header.headerValues.sig0 != 'P' || header.headerValues.sig1 != 'S' || header.headerValues.sig2 != 'F') {
		//If signatures don't match, fail out
		return NO;
	}
	
	
	if (header.headerValues.version != 1) {
		//Only ps1 format is supported
		return NO;
	}
    //Get the reserved and program sizes
    reservedSize = NSSwapLittleIntToHost(*(uint32_t *)(fileBytes + PSFReservedSizeOffset));
    compressedProgramSize = NSSwapLittleIntToHost(*(uint32_t *)(fileBytes + PSFCompressedProgramSizeOffset));
    compressedCRC32 = NSSwapLittleIntToHost(*(uint32_t *)(fileBytes + PSFCompressedProgramCRCOffset));
    compressedProgramData = fileBytes + PSFReservedDataStartOffset + reservedSize;
    
    //Handle parsing the tags, if any
    tagData = (char *)fileBytes + PSFReservedDataStartOffset + reservedSize + compressedProgramSize;
    uint32_t tagDataSize = [self.fileData length] - (PSFReservedDataStartOffset + reservedSize + compressedProgramSize);
    if (tagDataSize > 4) {
        NSString *tagString = [[NSString alloc] initWithBytes:tagData length:tagDataSize encoding:NSUTF8StringEncoding];
        NSLog(@"Got Tag String:%@",tagString);
        //First verify that the string starts with "[TAG]"
        NSString *tagSignatureString = [tagString substringToIndex:5];
        NSLog(@"Got tag signature:%@",tagSignatureString);
        if ([tagSignatureString isEqualToString:@"[TAG]"]) {
            //Signatures match so parse the tags
            self.tags = [NSMutableDictionary dictionary];
            NSString *actualTags = [tagString substringFromIndex:5]; //Grab everything after the signature
            NSArray *tagEntries = [actualTags componentsSeparatedByString:@"\n"];
            NSLog(@"Got Tag Entries:\n%@", tagEntries);
            for (NSString *tag in tagEntries) {
                if (tag && ![tag isEqualToString:@""]) {
                    NSArray *tagComponents = [tag componentsSeparatedByString:@"="];
                    [self.tags setObject:[tagComponents objectAtIndex:1] forKey:[tagComponents objectAtIndex:0]];
                }
            }
            NSLog(@"Parsed tags into dictionary:\n%@",self.tags);
            //Use the parsed tags to populate the standard tags
            self.tagTitle = [self.tags objectForKey:@"title"];
            self.tagArtist = [self.tags objectForKey:@"artist"];
            self.tagGame = [self.tags objectForKey:@"title"];
            self.tagYear = [self.tags objectForKey:@"title"];
            self.tagGenre = [self.tags objectForKey:@"title"];
            self.tagComment = [self.tags objectForKey:@"title"];
            self.tagCopyright = [self.tags objectForKey:@"title"];
            self.tagPSFBy = [self.tags objectForKey:@"title"];
        }
    }
    
	return YES;
}

@end
