//
//  EditingTypeTableViewController.m
//  Notebook
//
//  Created by Kubitski Vlad on 08.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "PhoneTypesViewController.h"
#import "UIViewController+Creation.h"

typedef void (^TypeWasChangedCompletion)(PhoneType);

@interface PhoneTypesViewController ()

@property (copy, nonatomic) TypeWasChangedCompletion typeWasChangedCompletion;
@property (assign, nonatomic) PhoneType type;

@end


@implementation PhoneTypesViewController

+ (void)presentOnController:(UIViewController*)context withType:(PhoneType)type withTypeWasChangedCompletion:(void (^)(PhoneType))typeWasChangedCompletion {
    
    PhoneTypesViewController *viewController = (PhoneTypesViewController *)[PhoneTypesViewController createFromStoryboard];
    viewController.typeWasChangedCompletion = typeWasChangedCompletion;
    viewController.type = type;
    [context presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)actionBack:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)formatTypeToString:(NSInteger)phoneType {
    
    NSString *result = nil;
    switch(phoneType) {
        case iPhone:
            result = @"iPhone";
            break;
        case Home:
            result = @"Home";
            break;
        case Mobile:
            result = @"Mobile";
            break;
        case HomeFAX:
            result = @"HomeFAX";
            break;
        case Work:
            result = @"Work";
            break;
        case Other:
            result = @"Other";
            break;
        case Main:
            result = @"Main";
            break;
            
        default:
            [NSException raise:NSGenericException format:@"Unexpected phoneType."];
    }
    return result;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhoneType type = (PhoneType)indexPath.row;
    self.typeWasChangedCompletion(type);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PhoneType type = countOfTypes;
    return type;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    
    NSString *nameType = [self formatTypeToString:indexPath.row];
    cell.textLabel.text = nameType;
    if ([[self formatTypeToString:self.type] isEqual:nameType]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

@end
