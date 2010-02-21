//
//  TWorkPeriod.m
//  Time Tracker
//
//  Created by Ivan Dramaliev on 10/18/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TWorkPeriod.h"
#import "TTTimeProvider.h"

@implementation TWorkPeriod

@synthesize date = _date;

- (id) init
{
	_startTime = nil;
	_endTime = nil;
	_comment = [[NSAttributedString alloc] init];
	return self;
}

- (void) setStartTime: (NSDate *) startTime
{
    if (startTime != _startTime) {
        [_startTime release];
        _startTime = nil;
        _startTime = [startTime retain];
        [self updateTotalTime];        
    }
}

- (void) setEndTime: (NSDate *) endTime
{
    if (endTime != _endTime) {
        [_endTime release];
        _endTime = nil;
        _endTime = [endTime retain];
        [self updateTotalTime];        
    }
}

- (void) setComment:(NSAttributedString*) aComment
{
	if (_comment == aComment) {
		return;
	}
	[_comment release];
    _comment = nil;
	_comment = [aComment retain];
}

- (void) setTotalTime:(int)time {
    _totalTime = time;
}

- (void) updateTotalTime
{
	if (_endTime == nil || _startTime == nil) {
		[self setTotalTime:0];
		return;
	}
	double timeInterval = [_endTime timeIntervalSinceDate: _startTime];
	[self setTotalTime:(int) timeInterval];
}

- (int) totalTime
{
	return _totalTime;
}

- (NSDate *) startTime
{
	return _startTime;
}

- (NSDate *) endTime
{
	return _endTime;
}

- (NSAttributedString *) comment
{
	if (_comment != nil) 
		return _comment;
	return [[[NSAttributedString alloc] initWithString:@""] autorelease];
}

- (NSString *) strComment
{
    if (_comment != nil) {
        return [_comment string];
    } 
    return @"";
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    //[super encodeWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        [coder encodeObject:_startTime forKey:@"WPStartTime"];
        [coder encodeObject:_endTime forKey:@"WPEndTime"];
		[coder encodeObject:_comment forKey:@"AttributedComment"];
		
    } else {
        [coder encodeObject:_startTime];
		[coder encodeObject:_endTime];
		// comment not supported here for data file compability reasons.
    }
    return;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    //self = [super initWithCoder:coder];
    if ( [coder allowsKeyedCoding] ) {
        // Can decode keys in any order
        [self setStartTime:[coder decodeObjectForKey:@"WPStartTime"]];
        [self setEndTime:[coder decodeObjectForKey:@"WPEndTime"]];
		id attribComment = [coder decodeObjectForKey:@"AttributedComment"];
		
		if ([attribComment isKindOfClass:[NSString class]]) {
			attribComment = [[[NSAttributedString alloc] initWithString:attribComment] autorelease];
		}
		if (attribComment == nil) {
			attribComment = [[[NSAttributedString alloc] initWithString:[coder decodeObjectForKey:@"Comment"]] autorelease];
		}
        [self setComment:attribComment];
    } else {
        // Must decode keys in same order as encodeWithCoder:
        [self setStartTime:[coder decodeObject]];
        [self setEndTime:[coder decodeObject]];
		// comment not supported here for data file compability reasons.
    }
	[self updateTotalTime];
    return self;
}

- (NSString*)serializeData:(NSString*) prefix separator:(NSString*)sep
{
	int hours = _totalTime / 3600;
	int minutes = _totalTime % 3600 / 60;
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d %H:%M" allowNaturalLanguage:NO]  autorelease];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d" allowNaturalLanguage:NO]  autorelease];
	NSString* result = [NSString stringWithFormat:@"%@%@\"%@\"%@\"%@\"%@\"%@\"%@\"%02d:%02d\"%@\"%@\"\n", prefix, sep, 
		[dateFormatter stringFromDate:_startTime], sep,
		[formatter stringFromDate:_startTime], sep, [formatter stringFromDate:_endTime], sep,
		hours, minutes, sep, [self strComment]];
	return result;
}

- (void)setParentTask:(TTask*) task 
{
	[_parent release];
	_parent = nil;
	_parent = [task retain];
}

- (TTask*)parentTask 
{
	return _parent;
}

-(NSInteger) weekday {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:(NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:_startTime];
    NSInteger result = [comp weekday];
    return result;
}


-(NSInteger) daysSinceDate:(NSDate*)date {
    TTTimeProvider *provider = [TTTimeProvider instance];
    NSDate* today = provider.todayStartTime;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                                   fromDate:date toDate:today options:0];
    return components.day;    
}

-(NSInteger) weeksSinceDate:(NSDate*)date {
    TTTimeProvider *provider = [TTTimeProvider instance];
    NSDate* today = provider.todayStartTime;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekCalendarUnit
                                                                       fromDate:date toDate:today options:0];
    return components.week;
}

-(NSInteger) monthsSinceDate:(NSDate*)date {
    TTTimeProvider *provider = [TTTimeProvider instance];
    NSDate* today = provider.todayStartTime;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit
                                                                   fromDate:date toDate:today options:0];
    return components.month;
}

-(NSInteger) daysSinceStart {
    return [self daysSinceDate:self.startTime];
}

-(NSInteger) daysSinceEnd {
    return [self daysSinceDate:self.endTime];
}

-(NSInteger) weeksSinceStart {
    return [self weeksSinceDate:self.startTime];
}

-(NSInteger) weeksSinceEnd {
    return [self weeksSinceDate:self.endTime];
}

-(NSInteger) monthsSinceStart {
    return [self monthsSinceDate:self.startTime];
}

-(NSInteger) monthsSinceEnd {
    return [self monthsSinceDate:self.endTime];
}

-(NSNumber*)startedDaysAgo:(NSNumber*)days fromDate:(NSDate*)referenceDate {
    return [NSNumber numberWithInt:1];
}

-(NSDate*)date {
    if (_date == nil) {
        self.date = [[TTTimeProvider instance] dateWithMidnight:self.startTime];
    }
    return _date;
}
@end
