//
//  Point.h
//  Notebook
//
//  Created by Kubitski Vlad on 17.10.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoordinatePoint : NSObject <NSCoding>

@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (strong, nonatomic) NSString *title;

@end
