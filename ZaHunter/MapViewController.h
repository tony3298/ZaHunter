//
//  MapViewController.h
//  ZaHunter
//
//  Created by Tony Dakhoul on 5/28/15.
//  Copyright (c) 2015 Tony Dakhoul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSArray *pizzerias;

@end
