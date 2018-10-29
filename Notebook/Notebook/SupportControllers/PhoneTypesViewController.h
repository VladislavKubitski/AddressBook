//
//  EditingTypeTableViewController.h
//  Notebook
//
//  Created by Kubitski Vlad on 08.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface PhoneTypesViewController : UITableViewController

+ (void)presentOnController:(UIViewController*)context withType:(PhoneType)type withTypeWasChangedCompletion:(void (^)(PhoneType))typeWasChangedCompletion;

@end
