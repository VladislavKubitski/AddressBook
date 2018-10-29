//
//  EditingInfoView.h
//  Notebook
//
//  Created by Kubitski Vlad on 06.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

typedef void(^InfoWasChangedBlock)(void);

@interface EditingInfoFIOView : UIView

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *surnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;

- (void)setPerson:(Person *)person withInfoBlock:(InfoWasChangedBlock)infoWasChangedBlock;

@end
