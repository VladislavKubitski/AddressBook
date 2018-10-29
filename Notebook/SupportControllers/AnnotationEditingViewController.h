//
//  EditingTypeMapTableViewController.h
//  Notebook
//
//  Created by Kubitski Vlad on 10.10.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnotationEditingViewController : UIViewController

+ (void)presentOnController:(UIViewController*)context withTitle:(NSString *)title titleWasSavedBlock:(void (^)(NSString *title))titleWasSavedBlock;

@end
