//
//  EditingTableViewCell.h
//  Notebook
//
//  Created by Kubitski Vlad on 07.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

typedef void (^ButtonTapBlock)(void);
typedef void (^TextFieldTapBlock)(NSString *);


@interface EditingInfoPhoneCell : UITableViewCell <UITextFieldDelegate>

- (void)setNumber:(NSString *)number withType:(NSString *)type withTextFieldTapBlock:(void(^)(NSString *number))textFieldTapBlock withButtonTapBlock:(void(^)(void))buttonTapBlock withKeyboardWasAppear:(void(^)(UITextField *, NSDictionary *))keyboardWasAppear withKeyboardWasDisappear:(void(^)(void))keyboardWasDisappear;

@end
