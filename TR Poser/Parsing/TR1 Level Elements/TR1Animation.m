//
//  TR1Animation.m
//  TR Poser
//
//  Created by Torsten Kammer on 13.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "TR1Animation.h"

#import "TR1Level.h"

@interface TR1Animation ()

@property (nonatomic, assign) NSUInteger unknown1;
@property (nonatomic, assign) NSUInteger unknown2;

@end

@implementation TR1Animation

+ (NSString *)structureDescriptionSource
{
	return @"bitu32 frameOffset;\
	bitu8 frameRate;\
	bitu8 frameSize;\
	bitu16 stateID;\
	bitu32 unknown1;\
	bitu32 unknown2;\
	bitu16 frameStart;\
	bitu16 frameEnd;\
	bitu16 nextAnimationIndex;\
	bitu16 nextFrameIndex;\
	bitu16 stateChangesCount;\
	bitu16 stateChangesOffset;\
	bitu16 animCommandCount;\
	bitu16 animCommandOffset;\
	@derived nextAnimation=level.animations[nextAnimationIndex];";
}

@dynamic nextAnimation;

- (NSUInteger)countOfStateChanges;
{
	return self.stateChangesCount;
}
- (TR1StateChange *)objectInStateChangesAtIndex:(NSUInteger)index;
{
	return [self.level.stateChanges objectAtIndex:index + self.stateChangesOffset];
}

@end