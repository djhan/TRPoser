//
//  TRDocument.m
//  TR Poser
//
//  Created by Torsten Kammer on 13.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "TRDocument.h"

#import "TR2Level.h"
#import "TRRenderLevel.h"
#import "TRRenderRoom.h"

@interface TRDocument ()

@property (nonatomic, retain) TRRenderLevel *renderLevel;

@end

@implementation TRDocument

- (id)init
{
    self = [super init];
    if (self) {
		// Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"TRDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	// Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
	// You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
	@throw exception;
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	// Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
	// You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
	// If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
	NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
	@throw exception;
	return YES;
}

- (IBAction)loadLevel:(id)sender;
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.allowedFileTypes = @[ @"phd", @"tr2", @"tr4" ];
	[panel beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSInteger result) {
		if (result != NSOKButton) return;
		
		NSData *data = [NSData dataWithContentsOfURL:panel.URL];
		NSAssert(data != nil, @"Can't find file %@", panel.URL);
		TR2Level *level = [[TR2Level alloc] initWithData:data];
		NSAssert(level != nil, @"Can't load level %@", panel.URL);
		
		if (!self.sceneView.scene)
		{
			self.sceneView.scene = [SCNScene scene];
			// Turn on the lights!
			SCNLight *light = [SCNLight light];
			light.type = SCNLightTypeDirectional;
			self.sceneView.scene.rootNode.light = light;
		}
		
		self.renderLevel = [[TRRenderLevel alloc] initWithLevel:level];
		
		SCNNode *newNode = [self.renderLevel createLevelNode];
		
		if (self.sceneView.scene.rootNode.childNodes.count != 0)
			[self.sceneView.scene.rootNode.childNodes[0] removeFromParentNode];
		
		[self.sceneView.scene.rootNode addChildNode:newNode];

	}];
}

@end
