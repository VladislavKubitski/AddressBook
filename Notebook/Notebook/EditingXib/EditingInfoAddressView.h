//
//  EditingAddressView.h
//  Notebook
//
//  Created by Kubitski Vlad on 24.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ContentWasChangedBlock)(NSInteger);

@interface EditingInfoAddressView : UIView <UITableViewDelegate, UITableViewDataSource>

- (void)setAddresses:(NSMutableArray *)addresses withController:(UIViewController *)viewController withContentWasChangedBlock:(ContentWasChangedBlock)contentWasChangedBlock;

@end
