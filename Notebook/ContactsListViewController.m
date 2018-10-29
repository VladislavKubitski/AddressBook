//
//  TableViewController.m
//  Notebook
//
//  Created by Kubitski Vlad on 27.07.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "ContactsListViewController.h"
#import "Person.h"
#import "Section.h"
#import "EditingInfoViewController.h"
#import "AddressBookService.h"

@interface ContactsListViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) NSMutableArray *persons;
@property (strong, nonatomic) NSOperation* currentOperation;
@property (strong, nonatomic) AddressBookService *addressBookContacts;

@end


@implementation ContactsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    self.persons = [NSMutableArray array];
    self.sections = [NSMutableArray array];
    [self getAllContacts];
}

- (void)getAllContacts {
    NSMutableArray *array = [NSMutableArray array];
    __weak ContactsListViewController *weakSelf = self;
    __block NSMutableArray *weakArray = array;
    AddressBookService *addressBookContacts = [[AddressBookService alloc] initWithUpdateContactsCompletion:^(NSMutableArray *mutableArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
                              weakArray = mutableArray;
                              [weakSelf updateContactsList:weakArray];
                          });
    }];
    [addressBookContacts getAllContact];
    self.addressBookContacts = addressBookContacts;
    [self updateContactsList:array];
}

- (void)updateContactsList:(NSMutableArray *)array {
    self.persons = [self sortPersons:array];
    [self generateSectionsInBackgroundFromArray:self.persons withFilter:self.searchBar.text];
}

- (NSMutableArray *)sortPersons:(NSMutableArray *)array {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"surname" ascending:YES];
    [array sortUsingDescriptors:@[descriptor]];
    return array;
}

- (void)generateSectionsInBackgroundFromArray:(NSMutableArray *)array withFilter:(NSString *)filterString  {
    
    [self.currentOperation cancel];
    
    __weak ContactsListViewController *weakSelf = self;
    
    self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSMutableArray* sections = [weakSelf distributionBySection:array withFilter:filterString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.sections = sections;
            [weakSelf.tableView reloadData];
            weakSelf.currentOperation = nil;
        });
    }];
    
    [self.currentOperation start];
}

- (NSMutableArray *)distributionBySection:(NSMutableArray *)array withFilter:(NSString *)filterString {
    
    NSMutableArray *sectionsArray = [NSMutableArray array];
    NSString *currentLetter = nil;
    for (int i = 0; i < [array count]; i++) {
        
        Person *person = [array objectAtIndex:i];
        NSString *string = person.surname;
        
        if ([filterString length] > 0 && [string rangeOfString:filterString].location == NSNotFound) {
            continue;
        }
        NSString *firstLetter = [string substringToIndex:1];
        
        Section *section = nil;
        if (![currentLetter isEqualToString:firstLetter]) {
            section = [Section new];
            section.name = firstLetter;
            section.items = [NSMutableArray array];
            currentLetter = firstLetter;
            [sectionsArray addObject:section];
        }
        else {
            section = [sectionsArray lastObject];
        }
        [section.items addObject:person];
    }
    return sectionsArray;
}

#pragma mark - Action

- (IBAction)actionAddButtonWasPressed:(UIBarButtonItem*)sender {
    
    Person *person = [Person new];
    [self.persons addObject:person];
    [self.addressBookContacts add:person];
    __weak ContactsListViewController *weakSelf = self;
    [EditingInfoViewController pushOnContext:self
                         withPerson:person
                       withUpdateBlock:^() {
                           [weakSelf.addressBookContacts update:person];
                           [weakSelf generateSectionsInBackgroundFromArray:[weakSelf sortPersons:weakSelf.persons] withFilter:weakSelf.searchBar.text];
                       }
                        removeBlock:^(){
                            [weakSelf.addressBookContacts delete:person];
                            [weakSelf.persons removeObject:person];
                                }];
}

- (IBAction)actionEditButtonWasPressed:(UIBarButtonItem *)sender {
    
    BOOL isEditing = self.tableView.isEditing;
    [self.tableView setEditing:!isEditing];
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    if (!isEditing) {
        item = UIBarButtonSystemItemDone;
    }
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item target:self action:@selector(actionEditButtonWasPressed:)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Delete";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Section *section = [self.sections objectAtIndex:indexPath.section];
    Person *person = [section.items objectAtIndex:indexPath.row];
    __weak ContactsListViewController *weakSelf = self;
    [EditingInfoViewController pushOnContext:self
                         withPerson:person
                       withUpdateBlock:^() {
                           [weakSelf.addressBookContacts update:person];
                           [weakSelf generateSectionsInBackgroundFromArray:[weakSelf sortPersons:weakSelf.persons] withFilter:weakSelf.searchBar.text];
                        }
                        removeBlock:^(){}];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Section *section = [self.sections objectAtIndex:indexPath.section];
        Person *person = [section.items objectAtIndex:indexPath.row];
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:section.items];
        [array removeObject:person];
        [self.addressBookContacts delete:person];
        section.items = array;
        
        if ([section.items count] == 0) {
            NSMutableArray *arraySection = [NSMutableArray arrayWithArray:self.sections];
            [arraySection removeObject:section];
            self.sections = arraySection;
        }
        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:indexPath.section];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if ([section.items count] == 0) {
            [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
        }
        [tableView endUpdates];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    Section *currentSection = [Section new];
    
    currentSection = [self.sections objectAtIndex:section];
    return [currentSection.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    Section *section = [self.sections objectAtIndex:indexPath.section];
    Person *person = [section.items objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", person.surname, person.name];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ((Section*)[self.sections objectAtIndex:section]).name;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self generateSectionsInBackgroundFromArray:self.persons withFilter:searchText];
}

@end
