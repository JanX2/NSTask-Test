//
//  NSTask_TestAppDelegate.m
//  NSTask Test
//
//  Created by Jan on 10.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSTask_TestAppDelegate.h"

@implementation NSTask_TestAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	NSTask *cliTask = [[NSTask alloc] init];

	// Force a certain architecture hierarchy:
	NSDictionary *env = [NSDictionary dictionaryWithObjectsAndKeys:@"i386,ppc", @"ARCHPREFERENCE", nil]; //x86_64,ppc64
	[cliTask setEnvironment:env];
	
	// Prepare the task: we launch the AppleScript via the 'osascript' CLI program
	[cliTask setLaunchPath: @"/usr/bin/arch"];
	[cliTask setArguments: [NSArray arrayWithObjects: @"/usr/bin/osascript", @"-e tell application \"Finder\" to display dialog \"Test\"", nil]];
	// The above will open a dialog in the Finder, blocking program execution. 
	// That way you can use Activity Monitor to check the architecture that is actually used by osascript in this example.

	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(cliDidEnd:)
												 name:NSTaskDidTerminateNotification
											   object:cliTask];
	[cliTask launch];

}


- (void)cliDidEnd:(NSNotification *)aNotification {
	NSTask	*cliTask = [aNotification object];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:NSTaskDidTerminateNotification 
												  object:cliTask];
		
	NSFileHandle *taskResults = [[cliTask standardOutput] fileHandleForReading];
	NSData *dataOut = [taskResults readDataToEndOfFile];
	
	NSLog(@"%@", [[[NSString alloc] initWithData:dataOut encoding:NSUTF8StringEncoding] autorelease]);
	
	int status = [cliTask terminationStatus];
	if (status == 0) {
		NSLog(@"Task succeeded.");
	}
	else if (status == 15) {
		NSLog(@"Task stopped by user.");
	}
	else {
		NSLog(@"Task failed.");
	}
	
	// clean up task object
	//[cliTask terminate];	// the 'terminate' isn't necessary
	[cliTask release];			
	cliTask = nil;
	
}


@end
