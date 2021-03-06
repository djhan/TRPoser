//
//  TR2RoomVertex.m
//  TR Poser
//
//  Created by Torsten Kammer on 13.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "TR2RoomVertex.h"

#import "TRInDataStream.h"
#import "TROutDataStream.h"

@implementation TR2RoomVertex

- (id)initFromDataStream:(TRInDataStream *)stream inLevel:(TR1Level *)level;
{
	if (!(self = [super initFromDataStream:stream inLevel:level])) return nil;
	
	self.attributes = [stream readUint16];
	self.lighting2 = [stream readUint16];
	
	return self;
}

- (void)writeToStream:(TROutDataStream *)stream;
{
	[super writeToStream:stream];
	
	[stream appendUint16:self.attributes];
	[stream appendUint16:self.lighting2];
}


@end
