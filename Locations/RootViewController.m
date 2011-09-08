//
//  RootViewController.m
//  Locations
//
//  Created by azu on 09/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "Event.h"

@implementation RootViewController

@synthesize eventsArray = eventsArray_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize locationManager = locationManager_;
@synthesize addButton = addButton_;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (CLLocationManager *)initLocationManager {
    if (self.locationManager != nil){
        return self.locationManager;
    }
    NSLog(@"Start Location Manager");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.delegate = self;
    return self.locationManager;
}
// デリゲート
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
        fromLocation:(CLLocation *)oldLocation {
    self.addButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    self.addButton.enabled = NO;
}
#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)addEvent {
    //To change the template use AppCode | Preferences | File Templates.
    CLLocation *location = [self.locationManager location];
    if (!location){
        return;
    }

    // Event エンティティの新規インスタンスを作成して設定
    Event *event = (Event *) [NSEntityDescription
            insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];

    CLLocationCoordinate2D coordinate = [location coordinate];
    [event setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
    [event setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
    [event setCreationDate:[NSDate date]];
    NSError *error = nil;
    // データの保存を行う
    if (![self.managedObjectContext save:&error]){
        // エラーを処理する
    }
    // insert　更新する
    [self.eventsArray insertObject:event atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
            withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
            atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
// タイムスタンプ用の日付フォーマッタ
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil){
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
// 緯度と経度用の数値フォーマッタ
    static NSNumberFormatter *numberFormatter = nil;
    if (numberFormatter == nil){
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:3];
    }
    static NSString *CellIdentifier = @"Cell";
// 新規セルをデキューまたは作成する
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc]
                                  initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]
                                  autorelease];
    }
    Event *event = (Event *) [self.eventsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dateFormatter stringFromDate:[event creationDate]];
    NSString *string = [NSString stringWithFormat:@"%@, %@", [numberFormatter stringFromNumber:[event latitude]],
                                                  [numberFormatter stringFromNumber:[event longitude]]];
    cell.detailTextLabel.text = string;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
        forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete){
// 指定のインデックスパスにある管理オブジェクトを削除する。
        NSManagedObject *eventToDelete = [self.eventsArray objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:eventToDelete];
// 配列とTable Viewを更新する。
        [self.eventsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                withRowAnimation:YES];
// 変更をコミットする
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]){

        }
// エラーを処理する。
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Locations";

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
            target:self action:@selector(addEvent)];
    self.addButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.addButton;
    // ロケーションマネージャを起動する
    [[self initLocationManager] startUpdatingLocation];
    self.eventsArray = [[NSMutableArray alloc] init];
    // fetch処理
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
            entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];

    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error]
                                                                      mutableCopy];
    if (mutableFetchResults == nil){
        // エラーを処理する
    }
    NSLog(@"%@", mutableFetchResults);
    self.eventsArray = mutableFetchResults;
    [mutableFetchResults release];
    [request release];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.eventsArray = nil;
    self.locationManager = nil;
    self.addButton = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [eventsArray_ release];
    [managedObjectContext_ release];
    [locationManager_ release];
    [addButton_ release];
    [super dealloc];
}

@end
