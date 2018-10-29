//
//  UIView+Creation.m
//  Notebook
//
//  Created by Kubitski Vlad on 05.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "UIView+Creation.h"

@implementation UIView (Creation)

+ (UIView *)loadFromXib {
    NSString *string = NSStringFromClass([self class]);
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:string owner:self options:nil];
    UIView *view = [array lastObject];
    return view;
}

@end
