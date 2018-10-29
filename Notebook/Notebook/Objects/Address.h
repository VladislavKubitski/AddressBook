//
//  Address.h
//  Notebook
//
//  Created by Kubitski Vlad on 05.10.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@property (strong, nonatomic) NSString *name; 
@property (strong, nonatomic) NSString *thoroughfare;
@property (strong, nonatomic) NSString *subThoroughfare; 
@property (strong, nonatomic) NSString *locality;
@property (strong, nonatomic) NSString *subLocality;
@property (strong, nonatomic) NSString *administrativeArea;
@property (strong, nonatomic) NSString *subAdministrativeArea;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSString *ISOcountryCode;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *inlandWater;
@property (strong, nonatomic) NSString *ocean;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

@end
