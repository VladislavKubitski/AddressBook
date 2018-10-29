//
//  Phone.h
//  Notebook
//
//  Created by Kubitski Vlad on 03.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneType.h"


@interface Phone : NSObject

@property (assign, nonatomic) PhoneType type;
@property (strong, nonatomic) NSString *number;

@end
