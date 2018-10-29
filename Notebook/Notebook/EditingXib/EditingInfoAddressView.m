//
//  EditingAddressView.m
//  Notebook
//
//  Created by Kubitski Vlad on 24.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "EditingInfoAddressView.h"
#import "EditingInfoAddressCell.h"
#import "EditingInfoAddAddressCell.h"
#import "AnnotationEditingViewController.h"
#import "MapViewController.h"
#import "Address.h"


@interface EditingInfoAddressView ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *addresses;
@property (strong, nonatomic) UIViewController *context;
@property (copy, nonatomic) ContentWasChangedBlock contentWasChangedBlock;

@end


@implementation EditingInfoAddressView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EditingInfoAddressCell" bundle:nil] forCellReuseIdentifier:@"EditingInfoAddressCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EditingInfoAddAddressCell" bundle:nil] forCellReuseIdentifier:@"EditingInfoAddAddressCell"];
    self.tableView.editing = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 0.1f;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:frame];
    
    self.tableView.allowsSelectionDuringEditing = YES;
}

- (void)setAddresses:(NSMutableArray *)addresses withController:(UIViewController *)viewController withContentWasChangedBlock:(ContentWasChangedBlock)contentWasChangedBlock {
    self.addresses = addresses;
    self.context = viewController;
    self.contentWasChangedBlock = contentWasChangedBlock;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.addresses count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifierCell = @"EditingInfoAddressCell";
    static NSString *identifierEmptyCell = @"EditingInfoAddAddressCell";
    
    if (indexPath.row == [self.addresses count]) {
        EditingInfoAddAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierEmptyCell];
        return cell;
    }
    
    Address *address = [self.addresses objectAtIndex:indexPath.row];
    EditingInfoAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCell];
    __weak Address *weakAddress = address;
    __weak EditingInfoAddressView *weakSelf = self;
    
    cell.blockMap = ^{
        [AnnotationEditingViewController presentOnController:self.context
                                              withTitle:address.title
                                             titleWasSavedBlock:^(NSString *title) {
                                                 weakAddress.title = title;
                                                 [weakSelf.tableView reloadData];
                                             }];
    };
    cell.titleLabel.text = address.title;
    cell.coutryLabel.text = address.country ? [NSString stringWithFormat:@"%@", address.country] : @"Country";
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row == [self.addresses count])
    ? UITableViewCellEditingStyleNone
    : UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.addresses removeObjectAtIndex:indexPath.row];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        [self.tableView endUpdates];
        
        self.contentWasChangedBlock(([self.addresses count] + 1) * 70);
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    __weak EditingInfoAddressView *weakSelf = self;
    if (indexPath.row == [self.addresses count]) {
        [MapViewController pushOnContext:self.context
                               withAddress:nil
                                 withAddressWasChangedBlock:^(Address *address) {
                                     
                                     [weakSelf.addresses addObject:address];
                                     [weakSelf.tableView beginUpdates];
                                     [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
                                     [weakSelf.tableView endUpdates];
                                     weakSelf.contentWasChangedBlock(([weakSelf.addresses count] + 1) * 70);
                                 }];
        self.contentWasChangedBlock(([self.addresses count] + 1) * 70);
    }
    else {
        Address *address = [self.addresses objectAtIndex:indexPath.row];
        
        [MapViewController pushOnContext:self.context
                               withAddress:address
                                 withAddressWasChangedBlock:^(Address *address) {
                                     [weakSelf.addresses replaceObjectAtIndex:indexPath.row withObject:address];
                                     weakSelf.contentWasChangedBlock(([weakSelf.addresses count] + 1) * 70);
                                     [weakSelf.tableView reloadData];
                                 }];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.addresses count]) {
        return NO;
    }
    else {
        return YES;
    }
}

@end
