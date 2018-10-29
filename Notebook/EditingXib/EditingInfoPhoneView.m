//
//  EditingPhoneView.m
//  Notebook
//
//  Created by Kubitski Vlad on 06.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "EditingInfoPhoneView.h"
#import "EditingInfoPhoneCell.h"
#import "EditingInfoAddPhoneCell.h"
#import "PhoneTypesViewController.h"
#import "UIViewController+Creation.h"
#import "Person.h"


@interface EditingInfoPhoneView ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIViewController *context;
@property (strong, nonatomic) NSMutableArray *phones;
@property (copy, nonatomic) ContentWasChangedBlock contentWasChangedBlock;
@property (copy, nonatomic) void(^keyboardWasAppear)(UITextField *, NSDictionary *);
@property (copy, nonatomic) void(^keyboardWasDisappear)(void);

@end


@implementation EditingInfoPhoneView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.tableView registerNib:[UINib nibWithNibName:@"EditingInfoPhoneCell" bundle:nil] forCellReuseIdentifier:@"EditingInfoPhoneCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EditingInfoAddPhoneCell" bundle:nil] forCellReuseIdentifier:@"EditingInfoAddPhoneCell"];
    self.tableView.editing = YES;
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 0.1f;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:frame];
    self.tableView.allowsSelectionDuringEditing = YES;
}

- (void)setPhones:(NSMutableArray *)phones withController:(UIViewController *)context withContentWasChangedBlock:(ContentWasChangedBlock)contentWasChangedBlock withKeyboardWasAppear:(void(^)(UITextField *, NSDictionary *))keyboardWasAppear withKeyboardWasDisappear:(void(^)(void))keyboardWasDisappear {
    self.phones = phones;
    self.context = context;
    self.contentWasChangedBlock = contentWasChangedBlock;
    self.keyboardWasAppear = keyboardWasAppear;
    self.keyboardWasDisappear = keyboardWasDisappear;
}

- (NSString*)formatTypeToString:(PhoneType)phoneType {
    
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.phones count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifierCell = @"EditingInfoPhoneCell";
    static NSString *identifierEmptyCell = @"EditingInfoAddPhoneCell";
    
    if (indexPath.row == [self.phones count]) {
        EditingInfoAddPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierEmptyCell];
        return cell;
    }
    
    Phone *phone = [self.phones objectAtIndex:indexPath.row];
    EditingInfoPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCell];
    
    [cell setNumber:phone.number withType:[self formatTypeToString:phone.type] withTextFieldTapBlock:^(NSString *number) {
                                phone.number = number;
                            }
         withButtonTapBlock:^{
                [PhoneTypesViewController presentOnController:self.context
                                                         withType:phone.type
                                                        withTypeWasChangedCompletion:^(PhoneType type) {
                                                            phone.type = type;
                                                            [self.tableView reloadData];
                                                        }];
         } withKeyboardWasAppear:self.keyboardWasAppear
        withKeyboardWasDisappear:self.keyboardWasDisappear];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row == [self.phones count])
            ? UITableViewCellEditingStyleNone
            : UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.phones removeObjectAtIndex:indexPath.row];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        [self.tableView endUpdates];
        
        self.contentWasChangedBlock(([self.phones count] + 1) * 40);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == [self.phones count]) {
        Phone *phone = [Phone new];
        [self.phones addObject:phone];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        [self.tableView endUpdates];
        
        self.contentWasChangedBlock(([self.phones count] + 1) * 40);
    }
    
}


@end
