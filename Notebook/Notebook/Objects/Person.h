//
//  Person.h
//  Notebook
//
//  Created by Kubitski Vlad on 28.07.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Phone.h"
#import "CoordinatePoint.h"

@interface Person : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *surname;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSMutableArray *phoneNumbers;
@property (strong, nonatomic) NSMutableArray *addresses;

- (Person *)makeDublicate;

@end
