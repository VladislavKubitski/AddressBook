//
//  UIView+AnnotationView.m
//  Notebook
//
//  Created by Kubitski Vlad on 01.10.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "UIView+AnnotationView.h"
#import <MapKit/MKAnnotationView.h>


@implementation UIView (AnnotationView)

- (MKAnnotationView *)superAnnotationView {
    
    if ([self isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView *)self;
    }
    
    if (!self.superview) {
        return nil;
    }
    
    return [self.superview superAnnotationView];
    
}

@end
