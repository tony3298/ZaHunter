//
//  Pizzeria.m
//  ZaHunter
//
//  Created by Tony Dakhoul on 5/28/15.
//  Copyright (c) 2015 Tony Dakhoul. All rights reserved.
//

#import "Pizzeria.h"

@implementation Pizzeria

-(instancetype)initWithName:(NSString *)name andLocation:(CLLocation *)location andDistance:(CLLocationDistance)distance{

    self = [super init];

    if(self ) {

        self.name = name;
        self.location = location;
        self.distanceFromUserLocation = distance;
    }

    return self;
}

@end
