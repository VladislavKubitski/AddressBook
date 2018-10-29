//
//  Point.m
//  Notebook
//
//  Created by Kubitski Vlad on 17.10.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "CoordinatePoint.h"

@implementation CoordinatePoint

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.title forKey:@"title"];
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.latitude = [coder decodeDoubleForKey:@"latitude"];
        self.longitude = [coder decodeDoubleForKey:@"longitude"];
        self.title = [coder decodeObjectForKey:@"title"];
    }
    return self;
}



@end
