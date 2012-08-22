//
//  TRRenderRoom.m
//  TR Poser
//
//  Created by Torsten Kammer on 21.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "TRRenderRoom.h"

#import "TRRenderRoomGeometry.h"
#import "TR1Room.h"
#import "TR1RoomFace.h"
#import "TR1MeshFace+TRRenderCategories.h"
#import "TR1StaticMesh.h"
#import "TR1StaticMeshInstance.h"
#import "TRRenderLevelResources.h"
#import "TRRenderMesh.h"

@interface TRRenderRoom ()
{
	SCNNode *node;
}

@end

@implementation TRRenderRoom

- (id)initWithRoomGeometry:(TRRenderRoomGeometry *)room;
{
	if (!(self = [super init])) return nil;
	
	_geometry = room;
	
	return self;
}

- (SCNNode *)node;
{
	if (node) return node;
	
	node = [SCNNode nodeWithGeometry:self.geometry.roomGeometry];
	
	for (TR1StaticMeshInstance *instance in self.room.staticMeshes)
	{
		TR1StaticMesh *staticMesh = instance.mesh;
		TRRenderMesh *mesh = [self.level.meshes objectAtIndex:staticMesh.meshIndex];
		
		SCNVector3 offset = SCNVector3Make((CGFloat) (instance.x - self.room.x) / 1024.0, (CGFloat) instance.y / 1024.0, (CGFloat) (instance.z - self.room.z) / 1024.0);
		
		SCNGeometry *meshGeometry = mesh.meshGeometry;
		NSColor *color = instance.color;
		if (color != nil)
		{
			SCNGeometry *coloredGeometry = [meshGeometry copy];
			
			for (NSUInteger i = 0; i < meshGeometry.materials.count; i++)
			{
				SCNMaterial *coloredMaterial = [meshGeometry.materials[i] copy];
				coloredMaterial.multiply.contents = color;
				[coloredGeometry replaceMaterialAtIndex:i withMaterial:coloredMaterial];
			}
			
			meshGeometry = coloredGeometry;
		}
		
		SCNNode *meshNode = [SCNNode nodeWithGeometry:meshGeometry];
		meshNode.position = offset;
		meshNode.rotation = SCNVector4Make(0.0, 1.0, 0.0, instance.rotationInRad);
		
		[node addChildNode:meshNode];
	}
	return node;
}

- (TR1Room *)room
{
	return self.geometry.room;
}

- (TRRenderLevelResources *)level
{
	return self.geometry.level;
}

- (SCNVector3)offset
{
	return self.geometry.offset;
}

@end
