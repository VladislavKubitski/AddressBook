//
//  Contacts.h
//  Notebook
//
//  Created by Kubitski Vlad on 30.09.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "ContactsListViewController.h"
#import "Person.h"
#import <Foundation/Foundation.h>


@interface AddressBookService : NSObject

- (instancetype)initWithUpdateContactsCompletion:(void(^)(NSMutableArray *))completion;

- (void)getAllContact;
- (void)add:(Person *)person;
- (void)update:(Person *)person;
- (void)delete:(Person *)person;

@end
