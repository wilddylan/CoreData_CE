//
//  ADAppDelegate.m
//  CoreData_CE
//
//  Created by Dylan on 14-10-11.
//  Copyright (c) 2014年 Dylan. All rights reserved.
//

#import "ADAppDelegate.h"
#import "ADCoreData.h"
#import "Dylan.h"
#import "Alice.h"

@implementation ADAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSLog(@"%s", __FUNCTION__);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // test
    ADCoreData * coreData = [ADCoreData shareInstanceWithStoreName:@"CoreData"];
    
    Dylan * dylan = [[Dylan alloc] initWithEntity:[NSEntityDescription entityForName:@"Dylan" inManagedObjectContext:coreData.manageContext] insertIntoManagedObjectContext:nil];
    dylan.age = @10;
    
    [dylan setName:@"Dylan"];
    
    NSLog(@"**************************************************");
    
    NSLog(@"first = %@", [coreData findByModel:dylan]);
    
    NSLog(@"**************************************************");
    
    [coreData create:dylan];
    NSLog(@"second = %@", [coreData findByModel:dylan]);
    NSLog(@"third = %@", [coreData findByModel:dylan predicateString:@"name = 'Dylan' age = '10'"]);
    NSLog(@"**************************************************");
    
    [coreData remove:dylan];
    NSLog(@"fourth = %@", [coreData findByModel:dylan]);
    NSLog(@"**************************************************");
    
    [coreData create:dylan];
    NSLog(@"fifth = %@", [coreData findByModel:dylan]);
    
    NSLog(@"**************************************************");
    
    Dylan * dylan1 = [[Dylan alloc] initWithEntity:[NSEntityDescription entityForName:@"Dylan" inManagedObjectContext:coreData.manageContext] insertIntoManagedObjectContext:nil];
    dylan1.name = @"dylan-1";
    
    [coreData modify:dylan1 predicateString:nil];
    NSLog(@"sixth = %@", [coreData findByModel:dylan]);
    NSLog(@"seventh = %@", [coreData findByModel:dylan1]);
    
    Alice * alice = [[Alice alloc] initWithEntity:[NSEntityDescription entityForName:@"Alice" inManagedObjectContext:coreData.manageContext] insertIntoManagedObjectContext:nil];
    alice.name = @"Alice";
    
//    [coreData create:alice];
    NSLog(@"eighth = %@", [coreData findByModel:alice]);
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"%s, %d", __FUNCTION__, __LINE__);
}


@end
