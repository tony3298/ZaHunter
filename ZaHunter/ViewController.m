//
//  ViewController.m
//  ZaHunter
//
//  Created by Tony Dakhoul on 5/28/15.
//  Copyright (c) 2015 Tony Dakhoul. All rights reserved.
//

#import "ViewController.h"
#import "Pizzeria.h"
#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *tableViewFooterLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *walkOrDriveSegmentedControl;


@property NSArray *pizzerias;

@property CLLocationManager *locationManager;

@property NSTimeInterval travelTime;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];

    [self.locationManager startUpdatingLocation];

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    NSLog(@"%@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    for (CLLocation *location in locations) {

        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            NSLog(@"Location found!");
            [self.locationManager stopUpdatingLocation];

            [self findPizzeriaNear:location];
        }
    }
}

-(void)findPizzeriaNear:(CLLocation *)location {

    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"Pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.01, 0.01));

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        NSArray *mapItems = response.mapItems;

        NSMutableArray *tempPizzeriaArray = [NSMutableArray new];

        int i = 0;

        for (MKMapItem *mapItem in mapItems) {

            CLLocationDistance distance = [location distanceFromLocation:mapItem.placemark.location];

            NSLog(@"%@, Location: %f, %f and distance: %f", mapItem.name, mapItem.placemark.location.coordinate.latitude, mapItem.placemark.coordinate.longitude, distance);

            if (distance <= 10000) {

                Pizzeria *pizzeria = [[Pizzeria alloc] initWithName:mapItem.name andLocation:mapItem.placemark.location andDistance:distance];
                pizzeria.mapItem = mapItem;

                [tempPizzeriaArray addObject:pizzeria];

                i++;
            }
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distanceFromUserLocation" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

        tempPizzeriaArray = [[tempPizzeriaArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];

//        for (int i = 0; i < 4; i++) {
//            self.
//        }

        NSMutableArray *temp = [NSMutableArray new];

        for (int i = 0; i < 4; i++) {
            [temp addObject:tempPizzeriaArray[i]];
        }

        self.pizzerias = temp;

        [self calculateTotalDistance];

        [self.tableView reloadData];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.pizzerias.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];

    Pizzeria *pizzeria = self.pizzerias[indexPath.row];

    cell.textLabel.text = pizzeria.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f Km", pizzeria.distanceFromUserLocation / 1000];

    return cell;
}

-(void)calculateTotalDistance{

    MKMapItem *previousMapItem = [MKMapItem mapItemForCurrentLocation];
    self.travelTime = 0;

    for (int i = 0; i < self.pizzerias.count; i++) {
        Pizzeria *pizzeria = self.pizzerias[i];
        MKMapItem *mapItem = pizzeria.mapItem;

//        NSLog(@"In for loop: %@", previousMapItem.description);

        MKDirectionsRequest *request = [MKDirectionsRequest new];
        request.source = previousMapItem;
        request.destination = mapItem;
        request.transportType = MKDirectionsTransportTypeWalking;

        NSLog(@"source (outside block): %@", request.source.description);
        NSLog(@"dest (outside block): %@", request.destination.description);

        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            NSArray *routes = response.routes;
            MKRoute *route = routes.firstObject;
            self.travelTime += route.expectedTravelTime;
            self.travelTime += 3000;

//            NSLog(@"In block: %@", previousMapItem.description);
//            NSLog(@"%f", self.travelTime);

            if (i == self.pizzerias.count - 1) {

                MKDirectionsRequest *request = [MKDirectionsRequest new];
                request.source = pizzeria.mapItem;
                request.destination = [MKMapItem mapItemForCurrentLocation];
                request.transportType = MKDirectionsTransportTypeWalking;

                NSLog(@"source (inside block): %@", request.source.description);
                NSLog(@"dest (inside block): %@", request.destination.description);

                MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                    NSArray *routes = response.routes;
                    MKRoute *route = routes.firstObject;
                    self.travelTime += route.expectedTravelTime;

                    NSLog(@"%f secs", self.travelTime);

                    self.tableViewFooterLabel.text = [NSString stringWithFormat:@"%.2f min to hunt all the za", self.travelTime / 60];
                }];
            }
        }];

        previousMapItem = pizzeria.mapItem;

    }
}

- (IBAction)onGetDirectionsButtonTapped:(UIButton *)sender {

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Pizzeria *pizzeria = self.pizzerias[indexPath.row];

    if (indexPath != nil) {

        MKDirectionsRequest *request = [MKDirectionsRequest new];
        request.source = [MKMapItem mapItemForCurrentLocation];
        request.destination = pizzeria.mapItem;

        if (self.walkOrDriveSegmentedControl.selectedSegmentIndex == 0) {
            request.transportType = MKDirectionsTransportTypeWalking;
        } else {
            request.transportType = MKDirectionsTransportTypeAutomobile;
        }

        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            NSArray *routes = response.routes;
            MKRoute *route = routes.firstObject;

            int i = 1;
            NSMutableString *directionsString = [NSMutableString string];
            for (MKRouteStep *step in route.steps) {
                NSLog(@"%@", step.instructions);
                [directionsString appendFormat:@"%d. %@\n", i, step.instructions];
                i++;
            }
            self.textView.text = directionsString;
        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    MapViewController *mapVC = segue.destinationViewController;

    mapVC.pizzerias = self.pizzerias;
    
}

@end
