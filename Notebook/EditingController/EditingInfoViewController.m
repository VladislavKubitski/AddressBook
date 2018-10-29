//
//  EditingFormViewController.m
//  Notebook
//
//  Created by Kubitski Vlad on 01.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "EditingInfoViewController.h"
#import "UIViewController+Creation.h"
#import "Person.h"
#import "Section.h"
#import "UIView+Creation.h"
#import "EditingInfoFIOView.h"
#import "EditingInfoPhoneView.h"
#import "ContactsListViewController.h"
#import "EditingInfoAddressView.h"
#import <MapKit/MapKit.h>

NSInteger const HeightPhoneCell = 40;
NSInteger const HeightAddressCell = 70;
NSInteger const HeightInfoView = 200;


@interface EditingInfoViewController ()

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *infoContainerView;
@property (weak, nonatomic) IBOutlet UIView *phoneContainerView;
@property (weak, nonatomic) IBOutlet UIView *addressContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressContainerViewHeightConstraint;

@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) Person *duplicatePerson;
@property (strong, nonatomic) EditingInfoFIOView *infoView;
@property (strong, nonatomic) EditingInfoPhoneView *phoneView;
@property (strong, nonatomic) EditingInfoAddressView *addressView;
@property (copy, nonatomic) UpdateBlock updateBlock;
@property (copy, nonatomic) RemoveBlock removeBlock;
@property (assign, nonatomic) BOOL saveWasPressed;

@end


@implementation EditingInfoViewController

+ (void)pushOnContext:(ContactsListViewController *)context withPerson:(Person *)person withUpdateBlock:(UpdateBlock)updateBlock removeBlock:(RemoveBlock)removeBlock {
    
    EditingInfoViewController *controller = (EditingInfoViewController *)[EditingInfoViewController createFromStoryboard];
    controller.person = person;
    controller.updateBlock = updateBlock;
    controller.removeBlock = removeBlock;
    [context.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeDublicate];
    
    self.saveWasPressed = NO;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(actionSaveButton:)];
    [self.navigationItem setRightBarButtonItem:saveButton];
    [self.navigationItem setTitle:@"Editing"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self createInfoView];
    [self createPhoneView];
    [self createAddressView];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.isMovingFromParentViewController) {
        if (!self.saveWasPressed) {
            self.removeBlock();
        }
    }
}

- (void)makeDublicate {
    self.duplicatePerson = [self.person makeDublicate];
}

- (void)createInfoView {
    EditingInfoFIOView *infoView = (EditingInfoFIOView *)[EditingInfoFIOView loadFromXib];
    __weak EditingInfoFIOView *weakInfoView = infoView;
    __weak EditingInfoViewController *weakSelf = self;
    [infoView setPerson:self.duplicatePerson
          withInfoBlock:^{
             weakSelf.duplicatePerson.name = weakInfoView.nameTextField.text;
             weakSelf.duplicatePerson.surname = weakInfoView.surnameTextField.text;
             weakSelf.duplicatePerson.nickname = weakInfoView.nicknameTextField.text;
          }];
    infoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, HeightInfoView);
    infoView.autoresizingMask = UIViewAutoresizingNone;
    self.infoView = infoView;
    [self.infoContainerView addSubview:infoView];
    self.infoContainerViewHeightConstraint.constant = HeightInfoView;
}

- (void)createPhoneView {
    NSInteger heightView = ([self.duplicatePerson.phoneNumbers count] + 1) * HeightPhoneCell;
    EditingInfoPhoneView *phoneView = (EditingInfoPhoneView *)[EditingInfoPhoneView loadFromXib];
    phoneView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, heightView);
    __weak EditingInfoPhoneView *weakPhoneView = phoneView;
    [phoneView setPhones:self.duplicatePerson.phoneNumbers
                         withController:self
                    withContentWasChangedBlock:^(NSInteger height){
                        self.phoneContainerViewHeightConstraint.constant = height;
                        CGRect rect = weakPhoneView.frame;
                        rect.size.height = height;
                        weakPhoneView.frame = rect;
                    }
                 withKeyboardWasAppear:^(UITextField *textField, NSDictionary *info) {
                     CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
                     
                         UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
                         self.scrollView.contentInset = contentInsets;
                         self.scrollView.scrollIndicatorInsets = contentInsets;
                         CGRect aRect = self.mainView.frame;
                         aRect.size.height -= kbSize.height;
                         if (!CGRectContainsPoint(aRect, textField.frame.origin) ) {
                             [self.scrollView scrollRectToVisible:textField.frame animated:YES];
                         }
                 }
               withKeyboardWasDisappear:^{
                   UIEdgeInsets contentInsets = UIEdgeInsetsZero;
                   self.scrollView.contentInset = contentInsets;
                   self.scrollView.scrollIndicatorInsets = contentInsets;
               }];
    phoneView.autoresizingMask = UIViewAutoresizingNone;
    self.phoneView = phoneView;
    [self.phoneContainerView addSubview:phoneView];
    self.phoneContainerViewHeightConstraint.constant = heightView;
}

- (void)createAddressView {
    NSInteger heightView = ([self.duplicatePerson.addresses count] + 1) * HeightAddressCell;
    self.addressContainerViewHeightConstraint.constant = heightView;
    EditingInfoAddressView *addressView = (EditingInfoAddressView *)[EditingInfoAddressView loadFromXib];
    addressView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, heightView);
    __weak EditingInfoAddressView *weakAddressView = addressView;
    [addressView setAddresses:self.duplicatePerson.addresses
              withController:self
         withContentWasChangedBlock:^(NSInteger height) {
                 self.addressContainerViewHeightConstraint.constant = height;
                 CGRect rect = weakAddressView.frame;
                 rect.size.height = height;
                 weakAddressView.frame = rect;
              }];
    addressView.autoresizingMask = UIViewAutoresizingNone;
    self.addressView = addressView;
    [self.addressContainerView addSubview:addressView];
}

- (IBAction)actionSaveButton:(UIBarButtonItem *)sender {
    
    if (([self.duplicatePerson.name isEqual:@""]) || ([self.duplicatePerson.surname isEqual:@""])) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                       message:@"Field name or surname is empty."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        self.person.name = self.duplicatePerson.name;
        self.person.surname = self.duplicatePerson.surname;
        self.person.nickname = self.duplicatePerson.nickname;
        NSMutableArray *phonesForRemove = [NSMutableArray array];
        for (Phone *phone in self.duplicatePerson.phoneNumbers) {
            if ([phone.number isEqual:@""]) {
                [phonesForRemove addObject:phone];
            }
        }
        [self.duplicatePerson.phoneNumbers removeObjectsInArray:phonesForRemove];
        self.person.phoneNumbers = self.duplicatePerson.phoneNumbers;
        self.person.addresses = self.duplicatePerson.addresses;
        self.saveWasPressed = YES;
        self.updateBlock();
        
        [self.navigationController popViewControllerAnimated:self];
    }
}

@end
