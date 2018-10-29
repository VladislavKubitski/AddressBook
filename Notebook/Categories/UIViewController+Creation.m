//
//  UIViewController+Creation.m
//  Notebook
//
//  Created by Kubitski Vlad on 01.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "UIViewController+Creation.h"

@implementation UIViewController (Creation)

+ (UIViewController *)createFromStoryboard {
    NSString *string = NSStringFromClass([self class]);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:string bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:string];
    return viewController;
}

@end
