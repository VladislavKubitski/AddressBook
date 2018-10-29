//
//  Address.m
//  Notebook
//
//  Created by Kubitski Vlad on 05.10.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "Address.h"

@implementation Address

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"";
        _thoroughfare = @"";
        _subThoroughfare = @"";
        _locality = @"";
        _subLocality = @"";
        _administrativeArea = @"";
        _subAdministrativeArea = @"";
        _postalCode = @"";
        _ISOcountryCode = @"";
        _country = @"";
        _inlandWater = @"";
        _ocean = @"";
        _title = @"";
        _latitude = 0;
        _longitude = 0;
    }
    return self;
}

@end
