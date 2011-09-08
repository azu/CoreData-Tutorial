//
//  LocationsAppDelegate.h
//  Locations
//
//  Created by azu on 09/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationsAppDelegate : NSObject <UIApplicationDelegate>
{
@private
    UINavigationController *navigationController_;
}

@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic, retain) IBOutlet UIWindow *window;

// コンテキストはアプリのコレクションを管理する
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end