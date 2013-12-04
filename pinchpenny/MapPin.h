//
//  MapPin.h
//  pinchpenny
//
//  Created by Tackable Inc on 10/24/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPin : NSObject <MKAnnotation>{
    
    NSString *title;
    NSString *subtitle;
    NSString *note;
    NSDictionary * dealDict;
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, strong) NSDictionary * dealDict;
@property (nonatomic, assign)CLLocationCoordinate2D coordinate;

@end
