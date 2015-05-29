//
//  MapViewController.m
//  ZaHunter
//
//  Created by Tony Dakhoul on 5/28/15.
//  Copyright (c) 2015 Tony Dakhoul. All rights reserved.
//

#import "MapViewController.h"
#import "Pizzeria.h"

@interface MapViewController () <MKMapViewDelegate>

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    for (Pizzeria *pizzeria in self.pizzerias) {
        MKMapItem *mapItem = pizzeria.mapItem;

        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = mapItem.placemark.coordinate;
        annotation.title = mapItem.placemark.name;

        [self.mapView addAnnotation:annotation];
    }

    self.mapView.showsUserLocation = YES;
//    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    [self zoomToFitMapAnnotations:self.mapView];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];

    if ([annotation isEqual:mapView.userLocation]) {
        return nil;
    }

    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.canShowCallout = YES;

    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    NSLog(@"Tap");

    NSArray *overlays = [self.mapView overlays];
    [self.mapView removeOverlays:overlays];

    MKPointAnnotation *annotation = mapView.selectedAnnotations[0];

    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:nil];
    MKMapItem *destinationItem = [[MKMapItem alloc] initWithPlacemark:placemark];

    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destinationItem;
    request.transportType = MKDirectionsTransportTypeWalking;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error : %@", error);
        }
        else {

            MKRoute *route = response.routes[0];
            [self.mapView addOverlay:route.polyline];
        }
    }];



}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {

    NSLog(@"renderer called");

    MKPolylineRenderer *polylineRender = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    polylineRender.lineWidth = 3.0f;
    polylineRender.strokeColor = [UIColor greenColor];
    return polylineRender;
}

-(void)zoomToFitMapAnnotations:(MKMapView*)mapView
{
    if([mapView.annotations count] == 0)
        return;

    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;

    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;

    for(MKPointAnnotation *annotation in mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);

        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }

    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides

    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

@end
