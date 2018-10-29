//
//  EditingInfoView.m
//  Notebook
//
//  Created by Kubitski Vlad on 06.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "EditingInfoFIOView.h"

@interface EditingInfoFIOView ()

@property (copy, nonatomic) InfoWasChangedBlock infoWasChangedBlock;

@end


@implementation EditingInfoFIOView

- (void)setPerson:(Person *)person withInfoBlock:(InfoWasChangedBlock)infoWasChangedBlock {
    self.nameTextField.text = person.name;
    self.surnameTextField.text = person.surname;
    self.nicknameTextField.text = person.nickname;
    self.infoWasChangedBlock = infoWasChangedBlock;
}

- (IBAction)actionEditingChanged:(UITextField *)sender {
    self.infoWasChangedBlock();
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.nameTextField]) {
        [self.surnameTextField becomeFirstResponder];
    }
    else {
        if ([textField isEqual:self.surnameTextField]) {
            [self.nicknameTextField becomeFirstResponder];
        }
        else {
            if ([textField isEqual:self.nicknameTextField]) {
                [self.nicknameTextField resignFirstResponder];
            }
        }
    }
    return YES;
}

@end
