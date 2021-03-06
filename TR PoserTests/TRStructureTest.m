//
//  TRSimpleStructureTest.m
//  TR Poser
//
//  Created by Torsten Kammer on 14.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "TRStructureTest.h"

#import "TRInDataStream.h"
#import "TROutDataStream.h"
#import "TRStructure.h"
#import "TRStructureDescription.h"

#pragma mark Test data structures

struct TestStruct {
	uint32_t dword;
	uint8_t byte1;
	uint8_t byte2;
	uint16_t word;
	int32_t negative;
} __attribute__((packed));

struct ComplexTestStruct {
	int32_t dword;
	uint8_t alignmentScrewup;
	struct TestStruct inherited;
	uint8_t followUp;
} __attribute__((packed));

struct FixedArrayTestStruct {
	uint16_t header;
	struct TestStruct array[2];
} __attribute__((packed));

// Length is variable in theory; in practice always 2.
struct VariableArrayTestStruct {
	uint16_t header;
	uint16_t length;
	struct TestStruct array[2];
} __attribute__((packed));

struct DerivedPropertyTestStruct {
	uint16_t index;
} __attribute__((packed));

struct FactorPropertyTestStruct {
	int16_t baseValue;
} __attribute__((packed));

@interface TRSimpleStructureTest_TestClass : TRStructure

@property (nonatomic, assign) NSUInteger dword;
@property (nonatomic, assign) NSUInteger byte1;
@property (nonatomic, assign) NSUInteger byte2;
@property (nonatomic, assign) NSUInteger word;
@property (nonatomic, assign) NSInteger negative;

@end

@implementation TRSimpleStructureTest_TestClass

+ (NSString *)structureDescriptionSource;
{
	return @"bitu32 dword; bitu8 byte1; bitu8 byte2; bitu16 word; bit32 negative";
}

@end

@interface TRSimpleStructureTest_ComplexTestClass : TRStructure

@property (nonatomic, assign) NSUInteger dword;
@property (nonatomic, assign) NSUInteger alignmentScrewup;
@property (nonatomic, retain) TRSimpleStructureTest_TestClass *inherited;
@property (nonatomic, assign) NSUInteger followUp;

@end

@implementation TRSimpleStructureTest_ComplexTestClass

+ (NSString *)structureDescriptionSource;

{
	return @"bitu32 dword; bitu8 alignmentScrewup; TRSimpleStructureTest_TestClass inherited; bitu8 followUp";
}

@end

@interface TRSimpleStructureTest_FixedArrayTestClass : TRStructure

@property (nonatomic, assign) NSUInteger header;
@property (nonatomic, retain) NSMutableArray *array;

@end

@implementation TRSimpleStructureTest_FixedArrayTestClass

+ (NSString *)structureDescriptionSource;
{
	return @"bitu16 header; TRSimpleStructureTest_TestClass array[2]";
}

@end

@interface TRSimpleStructureTest_VariableArrayTestClass : TRStructure

@property (nonatomic, assign) NSUInteger header;
@property (nonatomic, retain) NSMutableArray *array;

@end

@implementation TRSimpleStructureTest_VariableArrayTestClass

+ (NSString *)structureDescriptionSource;
{
	return @"bitu16 header; TRSimpleStructureTest_TestClass array[bitu16]";
}

@end

@interface TRSimpleStructureTest_DerivedPropertyTestClass : TRStructure

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, retain) NSArray *array;

@property (nonatomic, weak) id object;

@end

@implementation TRSimpleStructureTest_DerivedPropertyTestClass

@dynamic object;

+ (NSString *)structureDescriptionSource;
{
	return @"bitu16 index; @derived object=array[index]";
}

@end

@interface TRSimpleStructureTest_FactorPropertyTestClass : TRStructure

@property (nonatomic, assign) NSInteger baseValue;

@property (nonatomic, assign) double scaled1;
@property (nonatomic, assign) NSInteger scaled2;

@end

@implementation TRSimpleStructureTest_FactorPropertyTestClass

@dynamic scaled1, scaled2;

+ (NSString *)structureDescriptionSource;
{
	return @"bit16 baseValue; @factor scaled1=baseValue*3.5; @factor(signed) scaled2=baseValue*4";
}

@end

@interface TRSimpleStructureTest_ConstPropertyTestClass : TRStructure

@end

@implementation TRSimpleStructureTest_ConstPropertyTestClass

+ (NSString *)structureDescriptionSource;
{
	return @"const bit16=12";
}

@end

#pragma mark -
#pragma mark Test case

@implementation TRStructureTest

- (void)testSimpleRead
{
	struct TestStruct test = {
		UINT16_MAX + 2,
		128,
		12,
		259,
		-42
	};
	
	NSData *testData = [NSData dataWithBytes:&test length:sizeof(test)];
	TRInDataStream *stream = [[TRInDataStream alloc] initWithData:testData];
	
	TRSimpleStructureTest_TestClass *object = [[TRSimpleStructureTest_TestClass alloc] initFromDataStream:stream inLevel:nil];
	
	STAssertEquals(stream.position, sizeof(test), @"Position is less than size of test data");
	
	STAssertEquals((NSUInteger) test.dword, object.dword, @"Read dword does not equal.");
	STAssertEquals((NSUInteger) test.byte1, object.byte1, @"Read byte does not equal.");
	STAssertEquals((NSUInteger) test.byte2, object.byte2, @"Read byte does not equal.");
	STAssertEquals((NSUInteger) test.word, object.word, @"Read word does not equal.");
	STAssertEquals((NSInteger) test.negative, object.negative, @"Read negative value does not equal.");
}

- (void)testSimpleWrite
{
	TRSimpleStructureTest_TestClass *object = [[TRSimpleStructureTest_TestClass alloc] init];
	
	object.dword = UINT16_MAX + 2;
	object.byte1 = 128;
	object.byte2 = 12;
	object.word = 259;
	object.negative = -42;
	
	TROutDataStream *stream = [[TROutDataStream alloc] init];
	[object writeToStream:stream];
	
	struct TestStruct test;
	STAssertEquals(stream.length, sizeof(test), @"Length is not equal to test data");
	
	[stream.data getBytes:&test length:sizeof(test)];
	
	STAssertEquals((NSUInteger) test.dword, object.dword, @"Written dword does not equal.");
	STAssertEquals((NSUInteger) test.byte1, object.byte1, @"Written byte does not equal.");
	STAssertEquals((NSUInteger) test.byte2, object.byte2, @"Written byte does not equal.");
	STAssertEquals((NSUInteger) test.word, object.word, @"Written word does not equal.");
	STAssertEquals((NSInteger) test.negative, object.negative, @"Written negative value does not equal.");
}

- (void)testComplexRead;
{
	struct ComplexTestStruct test = {
		40000,
		129,
		{
			UINT16_MAX + 2,
			128,
			12,
			259,
			-42
		},
		0
	};
	
	NSData *testData = [NSData dataWithBytes:&test length:sizeof(test)];
	TRInDataStream *stream = [[TRInDataStream alloc] initWithData:testData];
	
	TRSimpleStructureTest_ComplexTestClass *object = [[TRSimpleStructureTest_ComplexTestClass alloc] initFromDataStream:stream inLevel:nil];
	
	STAssertEquals(stream.position, sizeof(test), @"Position is less than size of test data");
	
	STAssertEquals((NSUInteger) test.dword, object.dword, @"Read dword does not equal.");
	STAssertEquals((NSUInteger) test.alignmentScrewup, object.alignmentScrewup, @"Read byte does not equal.");
	
	STAssertEquals((NSUInteger) test.inherited.dword, object.inherited.dword, @"Read inherited dword does not equal.");
	STAssertEquals((NSUInteger) test.inherited.byte1, object.inherited.byte1, @"Read inherited byte does not equal.");
	STAssertEquals((NSUInteger) test.inherited.byte2, object.inherited.byte2, @"Read inherited byte does not equal.");
	STAssertEquals((NSUInteger) test.inherited.word, object.inherited.word, @"Read inherited word does not equal.");
	STAssertEquals((NSInteger) test.inherited.negative, object.inherited.negative, @"Read inherited negative value does not equal.");
	
	STAssertEquals((NSUInteger) test.followUp, object.followUp, @"Read byte does not equal.");
}

- (void)testComplexWrite;
{
	TRSimpleStructureTest_TestClass *inherited = [[TRSimpleStructureTest_TestClass alloc] init];
	
	inherited.dword = UINT16_MAX + 2;
	inherited.byte1 = 128;
	inherited.byte2 = 12;
	inherited.word = 259;
	inherited.negative = -42;
	
	TRSimpleStructureTest_ComplexTestClass *object = [[TRSimpleStructureTest_ComplexTestClass alloc] init];
	object.dword = 40000;
	object.alignmentScrewup = 129;
	object.inherited = inherited;
	object.followUp = 0;
	
	TROutDataStream *stream = [[TROutDataStream alloc] init];
	[object writeToStream:stream];
	
	struct ComplexTestStruct test;
	STAssertEquals(stream.length, sizeof(test), @"Length is not equal to test data");
	
	[stream.data getBytes:&test length:sizeof(test)];
	
	STAssertEquals(stream.length, sizeof(test), @"Length is not equal to size of test data");
	
	STAssertEquals((NSUInteger) test.dword, object.dword, @"Read dword does not equal.");
	STAssertEquals((NSUInteger) test.alignmentScrewup, object.alignmentScrewup, @"Read byte does not equal.");
	
	STAssertEquals((NSUInteger) test.inherited.dword, object.inherited.dword, @"Read inherited dword does not equal.");
	STAssertEquals((NSUInteger) test.inherited.byte1, object.inherited.byte1, @"Read inherited byte does not equal.");
	STAssertEquals((NSUInteger) test.inherited.byte2, object.inherited.byte2, @"Read inherited byte does not equal.");
	STAssertEquals((NSUInteger) test.inherited.word, object.inherited.word, @"Read inherited word does not equal.");
	STAssertEquals((NSInteger) test.inherited.negative, object.inherited.negative, @"Read inherited negative value does not equal.");
	
	STAssertEquals((NSUInteger) test.followUp, object.followUp, @"Read byte does not equal.");

}

- (void)testFixedArrayRead;
{
	struct FixedArrayTestStruct test = {
		19,
		{ {
			UINT16_MAX + 2,
			128,
			12,
			259,
			-42
		},
		{
			UINT16_MAX - 2,
			78,
			89,
			1024,
			-1024
		} }
	};
	
	NSData *testData = [NSData dataWithBytes:&test length:sizeof(test)];
	TRInDataStream *stream = [[TRInDataStream alloc] initWithData:testData];
	
	TRSimpleStructureTest_FixedArrayTestClass *object = [[TRSimpleStructureTest_FixedArrayTestClass alloc] initFromDataStream:stream inLevel:nil];
	
	STAssertEquals(stream.position, sizeof(test), @"Position is less than size of test data");
	
	STAssertEquals((NSUInteger) test.header, object.header, @"Read dword does not equal.");
	
	for (NSUInteger i = 0; i < 2; i++)
	{
		STAssertEquals((NSUInteger) test.array[i].dword, [[object.array objectAtIndex:i] dword], @"Read array dword does not equal.");
		STAssertEquals((NSUInteger) test.array[i].byte1, [[object.array objectAtIndex:i] byte1], @"Read array byte does not equal.");
		STAssertEquals((NSUInteger) test.array[i].byte2, [[object.array objectAtIndex:i] byte2], @"Read array byte does not equal.");
		STAssertEquals((NSUInteger) test.array[i].word, [[object.array objectAtIndex:i] word], @"Read array word does not equal.");
		STAssertEquals((NSInteger) test.array[i].negative, [[object.array objectAtIndex:i] negative], @"Read array negative value does not equal.");
	}
}

- (void)testFixedArrayWrite;
{
	TRSimpleStructureTest_TestClass *element1 = [[TRSimpleStructureTest_TestClass alloc] init];
	
	element1.dword = UINT16_MAX + 2;
	element1.byte1 = 128;
	element1.byte2 = 12;
	element1.word = 259;
	element1.negative = -42;
	
	TRSimpleStructureTest_TestClass *element2 = [[TRSimpleStructureTest_TestClass alloc] init];
	
	element2.dword = UINT16_MAX - 2;
	element2.byte1 = 78;
	element2.byte2 = 89;
	element2.word = 1024;
	element2.negative = -1024;
	
	TRSimpleStructureTest_FixedArrayTestClass *object = [[TRSimpleStructureTest_FixedArrayTestClass alloc] init];
	object.header = 19;
	object.array = [@[ element1, element2 ] mutableCopy];
	
	TROutDataStream *stream = [[TROutDataStream alloc] init];
	[object writeToStream:stream];
	
	struct FixedArrayTestStruct test;
	STAssertEquals(stream.length, sizeof(test), @"Length is not equal to test data");
	
	[stream.data getBytes:&test length:sizeof(test)];
	
	STAssertEquals(stream.length, sizeof(test), @"Position is less than size of test data");
	
	STAssertEquals((NSUInteger) test.header, object.header, @"Read dword does not equal.");
	
	for (NSUInteger i = 0; i < 2; i++)
	{
		STAssertEquals((NSUInteger) test.array[i].dword, [[object.array objectAtIndex:i] dword], @"Read array dword does not equal.");
		STAssertEquals((NSUInteger) test.array[i].byte1, [[object.array objectAtIndex:i] byte1], @"Read array byte does not equal.");
		STAssertEquals((NSUInteger) test.array[i].byte2, [[object.array objectAtIndex:i] byte2], @"Read array byte does not equal.");
		STAssertEquals((NSUInteger) test.array[i].word, [[object.array objectAtIndex:i] word], @"Read array word does not equal.");
		STAssertEquals((NSInteger) test.array[i].negative, [[object.array objectAtIndex:i] negative], @"Read array negative value does not equal.");
	}
}

- (void)testVariableArrayRead;
{
	struct VariableArrayTestStruct test = {
		19,
		2,
		{ {
			UINT16_MAX + 2,
			128,
			12,
			259,
			-42
		},
			{
				UINT16_MAX - 2,
				78,
				89,
				1024,
				-1024
			} }
	};
	
	NSData *testData = [NSData dataWithBytes:&test length:sizeof(test)];
	TRInDataStream *stream = [[TRInDataStream alloc] initWithData:testData];
	
	TRSimpleStructureTest_VariableArrayTestClass *object = [[TRSimpleStructureTest_VariableArrayTestClass alloc] initFromDataStream:stream inLevel:nil];
	
	STAssertEquals(stream.position, sizeof(test), @"Position is less than size of test data");
	
	STAssertEquals((NSUInteger) test.header, object.header, @"Read dword does not equal.");
	
	STAssertEquals((NSUInteger) test.length, object.array.count, @"Incorrect length field");
	
	for (NSUInteger i = 0; i < 2; i++)
	{
		STAssertEquals((NSUInteger) test.array[i].dword, [[object.array objectAtIndex:i] dword], @"Read array dword does not equal.");
		STAssertEquals((NSUInteger) test.array[i].byte1, [[object.array objectAtIndex:i] byte1], @"Read array byte does not equal.");
		STAssertEquals((NSUInteger) test.array[i].byte2, [[object.array objectAtIndex:i] byte2], @"Read array byte does not equal.");
		STAssertEquals((NSUInteger) test.array[i].word, [[object.array objectAtIndex:i] word], @"Read array word does not equal.");
		STAssertEquals((NSInteger) test.array[i].negative, [[object.array objectAtIndex:i] negative], @"Read array negative value does not equal.");
	}
}

- (void)testVariableArrayWrite;
{
	TRSimpleStructureTest_TestClass *element1 = [[TRSimpleStructureTest_TestClass alloc] init];
	
	element1.dword = UINT16_MAX + 2;
	element1.byte1 = 128;
	element1.byte2 = 12;
	element1.word = 259;
	element1.negative = -42;
	
	TRSimpleStructureTest_TestClass *element2 = [[TRSimpleStructureTest_TestClass alloc] init];
	
	element2.dword = UINT16_MAX - 2;
	element2.byte1 = 78;
	element2.byte2 = 89;
	element2.word = 1024;
	element2.negative = -1024;
	
	TRSimpleStructureTest_VariableArrayTestClass *object = [[TRSimpleStructureTest_VariableArrayTestClass alloc] init];
	object.header = 19;
	object.array = [@[ element1, element2 ] mutableCopy];
	
	TROutDataStream *stream = [[TROutDataStream alloc] init];
	[object writeToStream:stream];
	
	struct VariableArrayTestStruct test;
	STAssertEquals(stream.length, sizeof(test), @"Length is not equal to test data");
	
	[stream.data getBytes:&test length:sizeof(test)];
	
	STAssertEquals(stream.length, sizeof(test), @"Position is less than size of test data");
	
	STAssertEquals((NSUInteger) test.header, object.header, @"Read dword does not equal.");
	
	STAssertEquals((NSUInteger) test.length, object.array.count, @"Incorrect length field");
	
	for (NSUInteger i = 0; i < 2; i++)
	{
		STAssertEquals((NSUInteger) test.array[i].dword, [[object.array objectAtIndex:i] dword], @"Read array dword does not equal.");
		STAssertEquals((NSUInteger) test.array[i].byte1, [[object.array objectAtIndex:i] byte1], @"Read array byte does not equal.");
		STAssertEquals((NSUInteger) test.array[i].byte2, [[object.array objectAtIndex:i] byte2], @"Read array byte does not equal.");
		STAssertEquals((NSUInteger) test.array[i].word, [[object.array objectAtIndex:i] word], @"Read array word does not equal.");
		STAssertEquals((NSInteger) test.array[i].negative, [[object.array objectAtIndex:i] negative], @"Read array negative value does not equal.");
	}
}

- (void)testDerivedPropertyRead
{
	struct DerivedPropertyTestStruct test = {
		2
	};
	
	NSData *testData = [NSData dataWithBytes:&test length:sizeof(test)];
	TRInDataStream *stream = [[TRInDataStream alloc] initWithData:testData];
	
	TRSimpleStructureTest_DerivedPropertyTestClass *object = [[TRSimpleStructureTest_DerivedPropertyTestClass alloc] initFromDataStream:stream inLevel:nil];
	
	object.array = @[ @"zero", @"one", @"two", @"three" ];
	
	STAssertEqualObjects(object.object, @"two", @"Index should point to 'two'");
}

- (void)testDerivedPropertyWrite
{
	TRSimpleStructureTest_DerivedPropertyTestClass *object = [[TRSimpleStructureTest_DerivedPropertyTestClass alloc] init];
	
	object.array = @[ @"zero", @"one", @"two", @"three" ];
	object.object = @"two";
	
	TROutDataStream *stream = [[TROutDataStream alloc] init];
	[object writeToStream:stream];
	
	struct DerivedPropertyTestStruct test;
	STAssertEquals(stream.length, sizeof(test), @"Length is not equal to test data");
	
	[stream.data getBytes:&test length:sizeof(test)];
	
	STAssertEquals((NSUInteger) object.index, (NSUInteger) 2, @"Index should point to 2");
}

- (void)testFactorPropertyRead
{
	struct FactorPropertyTestStruct test = {
		2
	};
	
	NSData *testData = [NSData dataWithBytes:&test length:sizeof(test)];
	TRInDataStream *stream = [[TRInDataStream alloc] initWithData:testData];
	
	TRSimpleStructureTest_FactorPropertyTestClass *object = [[TRSimpleStructureTest_FactorPropertyTestClass alloc] initFromDataStream:stream inLevel:nil];
	
	STAssertEqualsWithAccuracy(object.scaled1, 7.0, 0.0001, @"Double scaling");
	STAssertEquals(object.scaled2, (NSInteger) 8, @"2*4 should be 8");
}

- (void)testFactorPropertyWrite
{
	TRSimpleStructureTest_FactorPropertyTestClass *object = [[TRSimpleStructureTest_FactorPropertyTestClass alloc] init];
	
	object.scaled1 = 7.0;
	
	TROutDataStream *stream = [[TROutDataStream alloc] init];
	[object writeToStream:stream];
	
	struct FactorPropertyTestStruct test;
	STAssertEquals(stream.length, sizeof(test), @"Length is not equal to test data");
	
	[stream.data getBytes:&test length:sizeof(test)];
	
	STAssertEquals(test.baseValue, (int16_t) 2, @"inverse scaling failed.");
}

- (void)testConstPropertyRead
{
	struct FactorPropertyTestStruct test = {
		12
	};
	
	NSData *testData = [NSData dataWithBytes:&test length:sizeof(test)];
	TRInDataStream *stream = [[TRInDataStream alloc] initWithData:testData];
	
	TRSimpleStructureTest_ConstPropertyTestClass *object = [[TRSimpleStructureTest_ConstPropertyTestClass alloc] initFromDataStream:stream inLevel:nil];
	
	STAssertEquals(stream.position, sizeof(test), @"Length is not equal to test data");
	
	STAssertTrue(object != nil, @"Object was not properly created");
}

- (void)testConstPropertyWrite
{
	TRSimpleStructureTest_ConstPropertyTestClass *object = [[TRSimpleStructureTest_ConstPropertyTestClass alloc] init];
	
	TROutDataStream *stream = [[TROutDataStream alloc] init];
	[object writeToStream:stream];
	
	struct FactorPropertyTestStruct test;
	STAssertEquals(stream.length, sizeof(test), @"Length is not equal to test data");
	
	[stream.data getBytes:&test length:sizeof(test)];
	
	STAssertEquals(test.baseValue, (int16_t) 12, @"inverse scaling failed.");
}

@end
