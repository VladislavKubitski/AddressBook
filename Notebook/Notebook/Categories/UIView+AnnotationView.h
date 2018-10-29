//
//  UIView+AnnotationView.h
//  Notebook
//
//  Created by Kubitski Vlad on 01.10.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKAnnotationView;

@interface UIView (AnnotationView)

- (MKAnnotationView *)superAnnotationView;

@end
