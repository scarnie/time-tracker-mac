//
//  TMetaTask.m
//  Time Tracker
//
//  Created by Rainer Burgstaller on 26.11.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TMetaTask.h"
#import "TTask.h"

@implementation TMetaTask

- (NSString *) name {
	return @"All Tasks";
}

- (NSMutableArray *) workPeriods {
	NSEnumerator *enumTasks = [_tasks objectEnumerator];
	TTask *task = nil;
	NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
	while ((task = [enumTasks nextObject]) != nil) {
		[result addObjectsFromArray:[task workPeriods]];
	}
	return result;
}

- (NSArray *) matchingWorkPeriods:(NSPredicate*) filter
{
    return [[self workPeriods] filteredArrayUsingPredicate:filter];
}

- (NSInteger) totalTime {
	NSEnumerator *enumTasks = [_tasks objectEnumerator];
	TTask *task = nil;
	int result = 0;
	while ((task = [enumTasks nextObject]) != nil) {
		result += [task totalTime];
	}
	return result;
}

- (void) updateTotalTime {
	NSEnumerator *enumTasks = [_tasks objectEnumerator];
	TTask *task = nil;
	
	while ((task = [enumTasks nextObject]) != nil) {
		[task updateTotalTime];
	}
}
- (void) setTasks:(NSArray*)tasks {
	if (_tasks == tasks) {
		return;
	}
	[_tasks release];
	_tasks = [tasks retain];
}


- (TTask*) taskForWorkPeriod:(TWorkPeriod*)aPeriod returnIndex:(int*)wpIndex {
	NSEnumerator *enumerator = [_tasks objectEnumerator];
	id aTask;
	*wpIndex = -1;
	
	while (aTask = [enumerator nextObject])
	{
		NSUInteger result = [[aTask workPeriods] indexOfObject:aPeriod];
		if (result != NSNotFound) {
			*wpIndex = result;
			return aTask;
		}
	}
	*wpIndex = -1;
	return nil;
}

- (id<ITask>) removeWorkPeriod:(TWorkPeriod*)period {
	int index = -1;
	TTask *task = [self taskForWorkPeriod:period returnIndex:&index];
	[[task workPeriods] removeObject:period];
	return self;
}

- (int) filteredTime:(NSPredicate*) filter
{
	if (filter == nil) {
		return [self totalTime];
	}
	NSEnumerator *enumPeriods = [[self matchingWorkPeriods:filter] objectEnumerator];
	id anObject;
	int result = 0;
 
	while (anObject = [enumPeriods nextObject])
	{
		result += [anObject totalTime];
	}
	return result;

}

-(int) taskId
{
    return -1;
}

-(NSComparisonResult) compare:(id<ITask>) o2 {
	if (o2 == self) {
		return NSOrderedSame;
	} else {
		return [self.name compare:o2.name];
	}
}

-(NSEnumerator*) objectEnumerator
{
    return [_tasks objectEnumerator];
}

-(BOOL) closed {
    return NO;
}

-(void) setFilterPredicate:(NSPredicate *)predicate {
	NSEnumerator *enumerator = [_tasks objectEnumerator];
	id<ITask> aTask;
	
	[self willChangeValueForKey:@"filteredDuration"];
	while (aTask = [enumerator nextObject])
	{
		aTask.filterPredicate = predicate;
	}
	[self didChangeValueForKey:@"filteredDuration"];
}

-(int) filteredDuration {
	int result = 0;
	NSEnumerator *enumerator = [_tasks objectEnumerator];
	id<ITask> aTask;
	
	while (aTask = [enumerator nextObject])
	{
		result += aTask.filteredDuration;
	}
	return result;
}

- (void) updateTotalBySeconds:(int)diffInSeconds sender:(id)theSender {
	// should not be called actually
	assert(NO);
}
@end
