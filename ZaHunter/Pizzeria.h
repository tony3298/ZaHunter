//
//  Pizzeria.h
//  ZaHunter
//
//  Created by Tony Dakhoul on 5/28/15.
//  Copyright (c) 2015 Tony Dakhoul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Pizzeria : NSObject

@property NSString *name;
@property CLLocation *location;
@property CLLocationDistance distanceFromUserLocation;
@property MKMapItem *mapItem;

-(instancetype)initWithName:(NSString *)name andLocation:(CLLocation *)location andDistance:(CLLocationDistance)distance;

@end
