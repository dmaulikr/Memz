//
//  AppDelegate.m
//  Memz
//
//  Created by Bastien Falcou on 12/15/15.
//  Copyright © 2015 Falcou. All rights reserved.
//

#import "AppDelegate.h"
#import "MZPushNotificationManager.h"
#import "MZMainViewController.h"

@interface AppDelegate ()

@property (assign, nonatomic) UIBackgroundTaskIdentifier powerOffDeviceBackgroundTaskIdentifier;
@property (strong, nonatomic) NSTimer *powerOffDeviceTimer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	// Saves changes in the application's managed object context before the application terminates.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	[[MZPushNotificationManager sharedManager] handleLocalNotification:notification];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self beginBackgroundTask];
	self.powerOffDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:5
																															target:self
																														selector:@selector(powerOffDevice:)
																														userInfo:nil
																														 repeats:NO];
}

- (void)powerOffDevice:(NSTimer *)timer {
	[timer invalidate];
	[[MZPushNotificationManager sharedManager] TEST];
}

- (void)beginBackgroundTask {
	self.powerOffDeviceBackgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		[self powerOffDevice:self.powerOffDeviceTimer];
	}];
}

- (void)endBackgroundTask {
	[[UIApplication sharedApplication] endBackgroundTask:self.powerOffDeviceBackgroundTaskIdentifier];
	self.powerOffDeviceBackgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

@end
