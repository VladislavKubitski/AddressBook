//
//  EditingPhoneView.h
//  Notebook
//
//  Created by Kubitski Vlad on 06.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"


typedef void(^ContentWasChangedBlock)(NSInteger);

@interface EditingInfoPhoneView : UIView <UITableViewDelegate, UITableViewDataSource>

- (void)setPhones:(NSMutableArray *)phones withController:(UIViewController *)viewController withContentWasChangedBlock:(ContentWasChangedBlock)contentWasChangedBlock withKeyboardWasAppear:(void(^)(UITextField *, NSDictionary *))keyboardWasAppear withKeyboardWasDisappear:(void(^)(void))keyboardWasDisappear;

@property (strong, nonatomic) Person *person;

@end
