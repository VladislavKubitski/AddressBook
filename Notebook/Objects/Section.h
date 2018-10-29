//
//  Section.h
//  Notebook
//
//  Created by Kubitski Vlad on 28.07.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Section : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *items;

@end
