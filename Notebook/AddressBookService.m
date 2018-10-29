//
//  Contacts.m
//  Notebook
//
//  Created by Kubitski Vlad on 30.09.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "AddressBookService.h"
#import "Address.h"
#import <Contacts/Contacts.h>
#import "CoordinatePoint.h"


@interface AddressBookService ()

@property (copy, nonatomic) void(^completion)(NSMutableArray *);

@end


@implementation AddressBookService

- (instancetype)initWithUpdateContactsCompletion:(void(^)(NSMutableArray *))completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

- (void)getAllContact {
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSArray *keys = @[CNContactFamilyNameKey,
                              CNContactGivenNameKey,
                              CNContactPhoneNumbersKey,
                              CNContactPostalAddressesKey,
                              CNContactIdentifierKey,
                              CNContactNicknameKey];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            
            if (error) {
                NSLog(@"error fetching contacts %@", error);
            }
            else {
                [self initializationPersons:cnContacts];
            }
        }
    }];
}

- (void)initializationPersons:(NSArray *)cnContacts {
    
    NSString *firstName;
    NSString *lastName;
    NSString *nickname;
    
    NSMutableArray *persons = [[NSMutableArray alloc] init];
    for (CNContact *contact in cnContacts) {
        
        NSMutableArray *contactNumbers = [[NSMutableArray alloc] init];
        NSMutableArray *contactAddresses = [[NSMutableArray alloc] init];
        firstName = contact.givenName;
        lastName = contact.familyName;
        nickname = contact.nickname;
        
        contactNumbers = [self fillPhones:contact];
        contactAddresses = [self fillAddresses:contact];
        
        Person *person = [[Person alloc] init];
        person.name = firstName;
        person.surname = lastName;
        person.identifier = contact.identifier;
        person.phoneNumbers = contactNumbers;
        person.addresses = contactAddresses;
        person.nickname = nickname;
        [persons addObject:person];
    }
    self.completion(persons);
}

- (NSMutableArray *)fillPhones:(CNContact *)contact {
    NSMutableArray *contactNumbers = [[NSMutableArray alloc] init];
    NSString *prefix = @"_$!<";
    NSString *postfix = @">!$_";
    NSString *type = @"iPhone";
    NSRange rangeStart;
    NSRange rangeFinish;
    NSRange rangeMiddle;
    for (CNLabeledValue *label in contact.phoneNumbers) {
        Phone *phone = [[Phone alloc] init];
        phone.number = [label.value stringValue];
        rangeStart = [label.label rangeOfString:prefix];
        rangeFinish = [label.label rangeOfString:postfix];
        if (rangeStart.length != 0) {
            rangeMiddle.location = rangeStart.length;
            rangeMiddle.length = rangeFinish.location - rangeStart.length;
            
            type = [label.label substringWithRange:rangeMiddle];
        }
        else {
            type = label.label;
        }
        if ([phone.number length] > 0) {
            phone.type = [self formatStringToType:type];
            [contactNumbers addObject:phone];
        }
    }
    return contactNumbers;
}

- (NSMutableArray *)fillAddresses:(CNContact *)contact {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *contactAddresses = [[NSMutableArray alloc] init];
    NSMutableArray *contactCoordinatePoints = [[NSMutableArray alloc] init];
    NSData *data = [userDefaults objectForKey:contact.identifier];
    contactCoordinatePoints = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    CoordinatePoint *coordinatePoint = [[CoordinatePoint alloc] init];
    for (CNLabeledValue *label in contact.postalAddresses) {
        Address *address = [[Address alloc] init];
        
        if ([contactCoordinatePoints count] != 0) {
            coordinatePoint = [contactCoordinatePoints objectAtIndex:[contact.postalAddresses indexOfObject:label]];
            address.longitude = coordinatePoint.longitude;
            address.latitude = coordinatePoint.latitude;
            address.title = coordinatePoint.title;
        }
        
        address.thoroughfare = [label.value street];
        address.subLocality = [label.value subLocality];
        address.locality = [label.value city];
        address.subAdministrativeArea = [label.value subAdministrativeArea];
        address.administrativeArea = [(CNPostalAddress *)label.value state];
        address.postalCode = [label.value postalCode];
        address.country = [label.value country];
        address.ISOcountryCode = [label.value ISOCountryCode];
        
        if (address) {
            [contactAddresses addObject:address];
        }
    }
    return contactAddresses;
}

- (void)add:(Person *)person {

    CNMutableContact *mutableContact = [[CNMutableContact alloc] init];
    person.identifier = mutableContact.identifier;
    
    [self initializationContact:mutableContact with:person];
    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest addContact:mutableContact toContainerWithIdentifier:store.defaultContainerIdentifier];
    
    NSError *error;
    if ([store executeSaveRequest:saveRequest error:&error]) {
        NSLog(@"save");
    }
    else {
        NSLog(@"save error");
    }
}

- (void)update:(Person *)person {
    NSArray *keys = @[CNContactFamilyNameKey,
                      CNContactGivenNameKey,
                      CNContactPhoneNumbersKey,
                      CNContactPostalAddressesKey,
                      CNContactIdentifierKey,
                      CNContactNicknameKey];
    CNContactStore *store = [[CNContactStore alloc] init];
    CNContact *contact = [store unifiedContactWithIdentifier:person.identifier keysToFetch:keys error:nil];

    CNMutableContact *mutableContact = contact.mutableCopy;
    
    [self initializationContact:mutableContact with:person];
    [self updateContact:mutableContact];

}

- (void)updateContact:(CNContact *)contact {
    CNMutableContact *mutableContact = contact.mutableCopy;
    
    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest updateContact:mutableContact];
    
    NSError *error = nil;
    if([store executeSaveRequest:saveRequest error:&error]) {
        NSLog(@"save");
    }
    else {
        NSLog(@"save error : %@", [error description]);
    }
}

- (void)delete:(Person *)person {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:person.identifier];
    NSMutableArray *oldCoordinatePoint = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    
    if ([oldCoordinatePoint count] != 0) {
        [userDefaults removeObjectForKey:person.identifier];
    }
    NSArray *keys = @[CNContactFamilyNameKey,
                      CNContactGivenNameKey,
                      CNContactPhoneNumbersKey,
                      CNContactPostalAddressesKey,
                      CNContactIdentifierKey,
                      CNContactNicknameKey];
    CNContactStore *store = [[CNContactStore alloc] init];
    CNContact *contact = [store unifiedContactWithIdentifier:person.identifier keysToFetch:keys error:nil];

    [self deleteContact:contact];
}

- (void)deleteContact:(CNContact *)contact {
    CNMutableContact *mutableContact = contact.mutableCopy;
    
    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *deleteRequest = [[CNSaveRequest alloc] init];
    [deleteRequest deleteContact:mutableContact];
    
    NSError *error;
    if([store executeSaveRequest:deleteRequest error:&error]) {
        NSLog(@"delete complete");
    }
    else {
        NSLog(@"delete error : %@", [error description]);
    }
}

- (PhoneType)formatStringToType:(NSString *)phoneType {
    
    PhoneType result = iPhone;
    if ([phoneType isEqual:@"iPhone"]) {
        result = iPhone;
    }
    if ([phoneType isEqual:@"Home"]) {
        result = Home;
    }
    if ([phoneType isEqual:@"Mobile"]) {
        result = Mobile;
    }
    if ([phoneType isEqual:@"HomeFAX"]) {
        result = HomeFAX;
    }
    if ([phoneType isEqual:@"Work"]) {
        result = Work;
    }
    if ([phoneType isEqual:@"Other"]) {
        result = Other;
    }
    if ([phoneType isEqual:@"Main"]) {
        result = Main;
    }
    
    return result;
}

- (NSString*)formatTypeToString:(NSInteger)phoneType {
    
    NSString *result = nil;
    switch(phoneType) {
        case iPhone:
            result = @"iPhone";
            break;
        case Home:
            result = @"Home";
            break;
        case Mobile:
            result = @"Mobile";
            break;
        case HomeFAX:
            result = @"HomeFAX";
            break;
        case Work:
            result = @"Work";
            break;
        case Other:
            result = @"Other";
            break;
        case Main:
            result = @"Main";
            break;
            
        default:
            [NSException raise:NSGenericException format:@"Unexpected phoneType."];
    }
    return result;
}

- (CNMutableContact *)initializationContact:(CNMutableContact *)mutableContact with:(Person *)person {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *data = [userDefaults objectForKey:person.identifier];
    NSMutableArray *oldCoordinatePoint = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    
    if ([oldCoordinatePoint count] != 0) {
        [userDefaults removeObjectForKey:person.identifier];
    }

    mutableContact.givenName = person.name;
    mutableContact.familyName = person.surname;
    mutableContact.nickname = person.nickname;
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    for (Phone *phone in person.phoneNumbers) {
        CNPhoneNumber *phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:phone.number];
        [labels addObject:[CNLabeledValue labeledValueWithLabel:[self formatTypeToString:phone.type] value:phoneNumber]];
    }
    mutableContact.phoneNumbers = [[NSArray alloc] initWithArray:labels];
    
    NSMutableArray *coordinatePoints = [[NSMutableArray alloc] init];
    labels = [[NSMutableArray alloc] init];
    for (Address *address in person.addresses) {
        CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
        postalAddress.street = address.thoroughfare;
        postalAddress.subLocality = address.subLocality;
        postalAddress.city = address.locality;
        postalAddress.subAdministrativeArea = address.subAdministrativeArea;
        postalAddress.state = address.administrativeArea;
        postalAddress.postalCode = address.postalCode;
        postalAddress.country = address.country;
        postalAddress.ISOCountryCode = address.ISOcountryCode;
        
        CoordinatePoint *point = [[CoordinatePoint alloc] init];
        point.latitude = address.latitude;
        point.longitude = address.longitude;
        point.title = address.title;
        [coordinatePoints addObject:point];
        [labels addObject:[CNLabeledValue labeledValueWithLabel:CNLabelHome value:postalAddress]];
    }
    
    NSData *dataArchiver = [NSKeyedArchiver archivedDataWithRootObject:coordinatePoints];
    [userDefaults setObject:dataArchiver forKey:person.identifier];
    
    mutableContact.postalAddresses = [[NSArray alloc] initWithArray:labels];
    return mutableContact;
}

@end
