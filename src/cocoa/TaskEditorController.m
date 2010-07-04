//
//  TaskEditorController.m
//
//  Created by Rainer Burgstaller on 02.07.10.
//  Copyright 2010 N/A. All rights reserved.
//

#import "TaskEditorController.h"

@implementation TaskEditorController

@synthesize task = _task;
@synthesize taskName = _taskName;
@synthesize completed = _completed;


// ============================
#pragma mark -
#pragma mark public API 
// ============================

- (IBAction)openSheet:(id)sender forWindow:(NSWindow*) parentWindow withTask:(TTask*)task
{
	self.task = task;
	if (task.name != nil) {
		self.taskName = task.name;
	} else {
		self.taskName = @"";
	}
	self.completed = task.closed;
	
	NSWindow *sheet = [self window];

	[sheet setAlphaValue:1];
	[NSApp beginSheet:sheet modalForWindow:parentWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}


- (IBAction)closeSheet:(id)sender
{
	NSWindow *sheet = [self window];
	[sheet orderOut:nil];
	[NSApp endSheet:sheet];
}

// ============================
#pragma mark -
#pragma mark Action handlers
// ============================

- (IBAction)applyAndClose:(id) sender {
	self.task.name = self.taskName;
	self.task.closed = self.completed;
	NSLog(@"applying new name: %@, completd %d",self.task.name, self.task.closed);
	[self closeSheet:sender];
}

// ============================
#pragma mark -
#pragma mark Property accessors 
// ============================

/* For some unkown reasons automatic implementation of the setter is bogus. */

-(void) setTaskName:(NSString*)name {
	if (name == _taskName) {
		return;
	}
	[_taskName release];
	_taskName = [name retain];
}

@end
