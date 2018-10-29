//
//  EditingAddressCell.m
//  Notebook
//
//  Created by Kubitski Vlad on 24.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "EditingInfoAddressCell.h"

@implementation EditingInfoAddressCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (IBAction)actionSegueMap:(id)sender {
    self.blockMap();
}
@end
