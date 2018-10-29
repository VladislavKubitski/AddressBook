//
//  EditingMapView.h
//  Notebook
//
//  Created by Kubitski Vlad on 24.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Address.h"
#import "UIView+Creation.h"
#import "CoordinatePoint.h"

@interface MapViewController : UIViewController

+ (void)pushOnContext:(UIViewController *)context withAddress:(Address *)address withAddressWasChangedBlock:(void(^)(Address *address))addressWasChangedBlock;

@end
