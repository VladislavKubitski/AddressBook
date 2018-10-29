//
//  ActivityIndicatorContainerView.m
//  Notebook
//
//  Created by Kubitski Vlad on 07.10.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "ActivityIndicatorContainerView.h"


@interface ActivityIndicatorContainerView ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ActivityIndicatorContainerView

- (void)startAnimating {
    [self.activityIndicatorView startAnimating];
}

- (void)stopAnimating {
    [self.activityIndicatorView stopAnimating];
}

@end
