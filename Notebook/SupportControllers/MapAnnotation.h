//
//  MapAnnotation.h
//  Notebook
//
//  Created by Kubitski Vlad on 26.09.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>


@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
