//
//  EditingFormViewController.h
//  Notebook
//
//  Created by Kubitski Vlad on 01.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "ContactsListViewController.h"

typedef void(^UpdateBlock)(void);
typedef void(^RemoveBlock)(void);

FOUNDATION_EXPORT NSInteger const HeightPhoneCell;
FOUNDATION_EXPORT NSInteger const HeightAddressCell;
FOUNDATION_EXPORT NSInteger const HeightInfoView;


@interface EditingInfoViewController : UIViewController

+ (void)pushOnContext:(ContactsListViewController *)context withPerson:(Person *)person withUpdateBlock:(UpdateBlock)updateBlock removeBlock:(RemoveBlock)removeBlock;

@end
