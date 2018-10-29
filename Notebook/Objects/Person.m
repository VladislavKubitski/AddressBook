//
//  Person.m
//  Notebook
//
//  Created by Kubitski Vlad on 28.07.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "Person.h"
#import "Address.h"


@implementation Person

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"";
        _surname = @"";
        _identifier = @"";
        _nickname = @"";
        _phoneNumbers = [NSMutableArray array];
        _addresses = [NSMutableArray array];
    }
    return self;
}

- (Person *)makeDublicate {
    Person *duplicatePerson = [[Person alloc] init];
    duplicatePerson.phoneNumbers = [NSMutableArray array];
    duplicatePerson.addresses = [NSMutableArray array];
    duplicatePerson.name = [self.name copy];
    duplicatePerson.identifier = [self.identifier copy];
    duplicatePerson.surname = [self.surname copy];
    duplicatePerson.nickname = [self.nickname copy];
    for (Phone *phone in self.phoneNumbers) {
        Phone *duplicatePhone = [[Phone alloc] init];
        duplicatePhone.number = [phone.number copy];
        duplicatePhone.type = phone.type;
        [duplicatePerson.phoneNumbers addObject:duplicatePhone];
    }
    for (Address *address in self.addresses) {
        Address *duplicateAddress = [[Address alloc] init];
        duplicateAddress.name = [address.name copy];
        duplicateAddress.thoroughfare = [address.thoroughfare copy];
        duplicateAddress.subThoroughfare = [address.subThoroughfare copy];
        duplicateAddress.locality = [address.locality copy];
        duplicateAddress.subLocality = [address.subLocality copy];
        duplicateAddress.administrativeArea = [address.administrativeArea copy];
        duplicateAddress.subAdministrativeArea = [address.subAdministrativeArea copy];
        duplicateAddress.postalCode = [address.postalCode copy];
        duplicateAddress.ISOcountryCode = [address.ISOcountryCode copy];
        duplicateAddress.country = [address.country copy];
        duplicateAddress.inlandWater = [address.inlandWater copy];
        duplicateAddress.ocean = [address.ocean copy];
        duplicateAddress.title = [address.title copy];
        duplicateAddress.latitude = address.latitude;
        duplicateAddress.longitude = address.longitude;
        [duplicatePerson.addresses addObject:duplicateAddress];
    }
    return duplicatePerson;
}

@end
