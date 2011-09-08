//
//  RootViewController.h
//  Locations
//
//  Created by azu on 09/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UITableViewController <CLLocationManagerDelegate> {
    NSManagedObjectContext *managedObjectContext;
    CLLocationManager *locationManager;
    UIBarButtonItem *addButton;
@private
    NSMutableArray *eventsArray_;
    NSManagedObjectContext *managedObjectContext_;
    CLLocationManager *locationManager_;
    UIBarButtonItem *addButton_;
}
@property(nonatomic, retain) NSMutableArray *eventsArray;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) UIBarButtonItem *addButton;

@end
