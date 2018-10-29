//
//  EditingTypeMapTableViewController.m
//  Notebook
//
//  Created by Kubitski Vlad on 10.10.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "AnnotationEditingViewController.h"
#import "UIViewController+Creation.h"


@interface AnnotationEditingViewController ()

@property (copy, nonatomic) void(^titleWasSavedBlock)(NSString *title);
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@end

@implementation AnnotationEditingViewController

+ (void)presentOnController:(UIViewController*)context withTitle:(NSString *)title titleWasSavedBlock:(void (^)(NSString *title))titleWasSavedBlock {
    AnnotationEditingViewController *viewController = (AnnotationEditingViewController *)[AnnotationEditingViewController createFromStoryboard];
    viewController.titleWasSavedBlock = titleWasSavedBlock;
    viewController.titleTextField.text = title;
    [context presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)actionBack:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSave:(UIBarButtonItem *)sender {
    self.titleWasSavedBlock(self.titleTextField.text);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.titleTextField]) {
        [self.titleTextField resignFirstResponder];
    }
    return YES;
}

@end
