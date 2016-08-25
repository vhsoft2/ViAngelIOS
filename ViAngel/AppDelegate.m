//
//  AppDelegate.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/17/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "AppDelegate.h"
#import "DataUtils.h"
#import "AgreementVC.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

UserData *userData;

NSTimeInterval postStatusInterval = 10;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ///
    ///Google Analytics
    ///
    // Optional: automatically send uncaught exceptions to Google Analytics.
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//
    if ([prefs boolForKey:@"hasRunBefore"] != YES)
    {
        // Add our default user object in Core Data
        userData = (UserData *)[NSEntityDescription insertNewObjectForEntityForName:@"UserData" inManagedObjectContext:self.managedObjectContext];
        [userData setGuardianFirstName:@""];
        [userData setGuardianLastName:@""];
        [userData setGuardianMobilePhone:@""];
        // Commit to core data
        NSError *error;
        if (![self.managedObjectContext save:&error])
            NSLog(@"Failed to add default user with error: %@", [error domain]);
        else {
            AgreementVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"AgreementVC"];
            [(UINavigationController*)self.window.rootViewController pushViewController:vc animated:NO];
        }
    }
    
    // Get a reference to the stardard user defaults
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    //Get the storyboard
//    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    // Check if the app has run before by checking a key in user defaults
//    if ([prefs boolForKey:@"hasRunBefore"] != YES)
//    {
//        // Add our default user object in Core Data
//        userData = (UserData *)[NSEntityDescription insertNewObjectForEntityForName:@"UserData" inManagedObjectContext:self.managedObjectContext];
//        [userData setGuardianFirstName:@""];
//        [userData setGuardianLastName:@""];
//        [userData setGuardianMobilePhone:@""];
//        // Commit to core data
//        NSError *error;
//        if (![self.managedObjectContext save:&error])
//            NSLog(@"Failed to add default user with error: %@", [error domain]);
//        else {
//            GuardianRegistrationVC *gvc = [storyboard instantiateViewControllerWithIdentifier:@"GuardianRegistrationVC"];
//            [(UINavigationController*)self.window.rootViewController pushViewController:gvc animated:NO];
//        }
//    } else {
//        elderStatusVC = [storyboard instantiateViewControllerWithIdentifier:@"ElderStatusVC"];
//        [(UINavigationController*)self.window.rootViewController pushViewController:elderStatusVC animated:NO];
//    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startFetchingLocationsContinously) name:@"rrrr" object:nil];
//    //Set timer to report location
//    statusTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:NO];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //Start backgrounding
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    /*UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
     //check to see if navbar "get" worked
     if (navigationController.viewControllers)
     //look for the nav controller in tab bar views
     for (UINavigationController *view in navigationController.viewControllers) {
     if ([view isKindOfClass:[ElderStatusVC class]])
     elderStatusVC = (ElderStatusVC *) view;
     }*/
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Utils

#pragma mark - Handle server messages
#pragma mark - HTTP



#pragma mark - Background

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Background fetch started");
    /* Set up Local Notifications
     [[UIApplication sharedApplication] cancelAllLocalNotifications];
     UILocalNotification *localNotification = [[UILocalNotification alloc] init];
     localNotification.fireDate = [NSDate date];
     localNotification.alertBody = [NSString stringWithFormat:@"Test time."];
     localNotification.soundName = UILocalNotificationDefaultSoundName;
     localNotification.applicationIconBadgeNumber = -1;
     [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
     completionHandler(UIBackgroundFetchResultNewData);*/
    NSLog(@"Background fetch completed");
}

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:0.01];//UIApplicationBackgroundFetchIntervalMinimum];
    return true;
}

-(void)startFetchingLocationsContinously {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ViGuard" withExtension:@"mom"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ViGuard.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
