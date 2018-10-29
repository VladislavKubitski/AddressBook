//
//  Phone.m
//  Notebook
//
//  Created by Kubitski Vlad on 03.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "Phone.h"

@implementation Phone

- (instancetype)init
{
    self = [super init];
    if (self) {
        _number = @"";
        _type = iPhone;
    }
    return self;
}

@end
