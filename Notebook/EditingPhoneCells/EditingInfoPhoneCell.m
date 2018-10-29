//
//  EditingTableViewCell.m
//  Notebook
//
//  Created by Kubitski Vlad on 07.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "EditingInfoPhoneCell.h"
#import "PhoneTypesViewController.h"


@interface EditingInfoPhoneCell ()

@property (weak, nonatomic) IBOutlet UIButton *selectTypeButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (nonatomic, copy) ButtonTapBlock buttonTapBlock;
@property (nonatomic, copy) TextFieldTapBlock textFieldTapBlock;
@property (copy, nonatomic) void(^keyboardWasAppear)(UITextField *, NSDictionary *);
@property (copy, nonatomic) void(^keyboardWasDisappear)(void);
@property (strong, nonatomic) UITextField *activeTextField;

@end

@implementation EditingInfoPhoneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self registerForKeyboardNotifications];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    self.keyboardWasAppear(self.activeTextField, info);
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    self.keyboardWasDisappear();
}

- (void)setNumber:(NSString *)number withType:(NSString *)type withTextFieldTapBlock:(void(^)(NSString *number))textFieldTapBlock withButtonTapBlock:(void(^)(void))buttonTapBlock withKeyboardWasAppear:(void(^)(UITextField *, NSDictionary *))keyboardWasAppear withKeyboardWasDisappear:(void(^)(void))keyboardWasDisappear {
    self.phoneTextField.text = number;
    self.buttonTapBlock = buttonTapBlock;
    self.textFieldTapBlock = textFieldTapBlock;
    self.keyboardWasAppear = keyboardWasAppear;
    self.keyboardWasDisappear = keyboardWasDisappear;
    [self.selectTypeButton setTitle:type forState:UIControlStateNormal];
}

- (IBAction)actionSelectType:(UIButton *)sender {
    self.buttonTapBlock();
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.phoneTextField]) {
        [self.phoneTextField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
    }
    
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray* validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
    newString = [validComponents componentsJoinedByString:@""];
    
    static const int localNumberMaxLength = 7;
    static const int areaCodeMaxLength = 3;
    static const int countryCodeMaxLength = 3;
    
    if ([newString length] > localNumberMaxLength + areaCodeMaxLength + countryCodeMaxLength) {
        return NO;
    }
    
    
    NSMutableString* resultString = [NSMutableString string];

    NSInteger localNumberLength = MIN([newString length], localNumberMaxLength);
    
    if (localNumberLength > 0) {
        
        NSString* number = [newString substringFromIndex:(int)[newString length] - localNumberLength];
        
        [resultString appendString:number];
        
        if ([resultString length] > 3) {
            [resultString insertString:@"-" atIndex:3];
        }
        
    }
    
    if ([newString length] > localNumberMaxLength) {
        
        NSInteger areaCodeLength = MIN((int)[newString length] - localNumberMaxLength, areaCodeMaxLength);
        
        NSRange areaRange = NSMakeRange((int)[newString length] - localNumberMaxLength - areaCodeLength, areaCodeLength);
        
        NSString* area = [newString substringWithRange:areaRange];
        
        area = [NSString stringWithFormat:@"(%@) ", area];
        
        [resultString insertString:area atIndex:0];
    }
    
    if ([newString length] > localNumberMaxLength + areaCodeMaxLength) {
        
        NSInteger countryCodeLength = MIN((int)[newString length] - localNumberMaxLength - areaCodeMaxLength, countryCodeMaxLength);
        
        NSRange countryCodeRange = NSMakeRange(0, countryCodeLength);
        
        NSString* countryCode = [newString substringWithRange:countryCodeRange];
        
        countryCode = [NSString stringWithFormat:@"+%@ ", countryCode];
        
        [resultString insertString:countryCode atIndex:0];
    }
    
    textField.text = resultString;
    self.textFieldTapBlock(resultString);
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}

@end
