//
//  EditingAddressCell.h
//  Notebook
//
//  Created by Kubitski Vlad on 24.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^BlockGoToMap)(void);

@interface EditingInfoAddressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *coutryLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;

@property (copy, nonatomic) BlockGoToMap blockMap;

- (IBAction)actionSegueMap:(id)sender;



@end
