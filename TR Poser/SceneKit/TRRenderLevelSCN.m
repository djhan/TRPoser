//
//  TRRenderLevel.m
//  TR Poser
//
//  Created by Torsten Kammer on 22.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "TRRenderLevelSCN.h"

#import "TRRenderLevelResourcesSCN.h"
#import "TRRenderRoomSCN.h"
#import "TRRenderMoveableSCN.h"
#import "TR1Level.h"
#import "TR1Item.h"

@interface TRRenderLevelSCN ()
{
	SCNNode *rootNode;
}

@end

@implementation TRRenderLevelSCN

- (id)initWithResources:(TRRenderLevelResourcesSCN *)resources;
{
	if (!(self = [super init])) return nil;
	
	_resources = resources;
	
	NSMutableArray *rooms = [[NSMutableArray alloc] initWithCapacity:resources.rooms.count];
	for (TRRenderRoomGeometrySCN *geometry in resources.rooms)
	{
		TRRenderRoomSCN *room = [[TRRenderRoomSCN alloc] initWithRoomGeometry:geometry];
		[rooms addObject:room];
	}
	_rooms = [rooms copy];
	
	NSMutableArray *moveables = [[NSMutableArray alloc] initWithCapacity:resources.level.items.count];
	for (TR1Item *item in self.resources.level.items)
	{
		TRRenderMoveableDescription *description = [self.resources moveableForObjectID:item.objectID];
		if (!description)
			continue; // Object ID could be pointing to sprite or similar.
		
		TRRenderMoveableSCN *moveable = [[TRRenderMoveableSCN alloc] initWithDescription:description];
		
		TRRenderRoomSCN *parentRoom = [_rooms objectAtIndex:item.roomIndex];
		moveable.offset = SCNVector3Make((CGFloat) item.x / 1024.0 - parentRoom.offset.x,
										 (CGFloat) item.y / 1024.0 - parentRoom.offset.y,
										 (CGFloat) item.z / 1024.0 - parentRoom.offset.z);
		moveable.rotation = item.rotationInRad;
		moveable.room = parentRoom;
		
		[moveables addObject:moveable];
	}
	_moveables = [moveables copy];
	
	return self;
}

- (SCNNode *)rootNode
{
	if (rootNode) return rootNode;
	
	rootNode = [SCNNode node];
	
	for (TRRenderRoomSCN *room in self.rooms)
	{
		SCNNode *node = room.node;
		SCNVector3 offset = room.offset;
		
		node.position = offset;
		[rootNode addChildNode:node];
	}
	
	return rootNode;

}

@end
