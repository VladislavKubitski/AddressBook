//
//  EditingMapView.m
//  Notebook
//
//  Created by Kubitski Vlad on 24.08.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

#import "MapViewController.h"
#import "UIViewController+Creation.h"
#import "MapAnnotation.h"
#import "ActivityIndicatorContainerView.h"
#import "UIView+AnnotationView.h"
#import <MapKit/MapKit.h>


@interface MapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) Address *address;
@property (copy, nonatomic) void(^addressWasChangedBlock)(Address *address);
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (assign, nonatomic) BOOL pinWillAppeared;
@property (strong, nonatomic) ActivityIndicatorContainerView *activityIndicatorContainerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)actionLongPress:(UILongPressGestureRecognizer *)sender;

@end

@implementation MapViewController

+ (void)pushOnContext:(UIViewController *)context withAddress:(Address *)address withAddressWasChangedBlock:(void(^)(Address *address))addressWasChangedBlock {
    MapViewController *viewController = (MapViewController *)[MapViewController createFromStoryboard];
    viewController.address = address;
    viewController.addressWasChangedBlock = addressWasChangedBlock;
    [context.navigationController pushViewController:viewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pinWillAppeared = YES;
    [self.mapView setZoomEnabled:YES];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(actionSaveButton:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.geoCoder = [[CLGeocoder alloc] init];
    if (!self.address) {
        self.address = [[Address alloc] init];
    }
    else {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.address.latitude, self.address.longitude);
        [self creareAnnotation:coordinate];
    }
}

#pragma mark - Actions

- (void)actionSaveButton:(UIBarButtonItem *)sender {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.address.latitude
                                                      longitude:self.address.longitude];
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    __weak MapViewController *weakSelf = self;
    [self.geoCoder
     reverseGeocodeLocation:location
     completionHandler:^(NSArray *placemarks, NSError *error) {
         if (!error && [placemarks count] > 0) {
             MKPlacemark *placemark = [placemarks firstObject];
             [weakSelf fillAddress:placemark];
             [weakSelf.activityIndicatorContainerView stopAnimating];
         }
         [weakSelf.navigationController popViewControllerAnimated:weakSelf];
     }];
    ActivityIndicatorContainerView *activityIndicatorContainerView = (ActivityIndicatorContainerView *)[ActivityIndicatorContainerView loadFromXib];
    [self.activityIndicatorContainerView startAnimating];
    [self.view addSubview:activityIndicatorContainerView];
}

- (void)fillAddress:(MKPlacemark *)placemark {
    __weak MapViewController *weakSelf = self;
    weakSelf.address.name = placemark.name;
    weakSelf.address.thoroughfare = placemark.thoroughfare;
    weakSelf.address.subThoroughfare = placemark.subThoroughfare;
    weakSelf.address.locality = placemark.locality;
    weakSelf.address.subLocality = placemark.subLocality;
    weakSelf.address.administrativeArea = placemark.administrativeArea;
    weakSelf.address.subAdministrativeArea = placemark.subAdministrativeArea;
    weakSelf.address.postalCode = placemark.postalCode;
    weakSelf.address.ISOcountryCode = placemark.ISOcountryCode;
    weakSelf.address.country = placemark.country;
    weakSelf.address.inlandWater = placemark.inlandWater;
    weakSelf.address.ocean = placemark.ocean;
    
    weakSelf.addressWasChangedBlock(weakSelf.address);
}

- (IBAction)actionLongPress:(UILongPressGestureRecognizer *)sender {
    
    if (self.pinWillAppeared) {
        CGPoint point = [sender locationInView:self.mapView];
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        [self createNewAnnotation:coordinate];
        self.pinWillAppeared = NO;
        self.address.latitude = coordinate.latitude;
        self.address.longitude = coordinate.longitude;
    }
}

- (void)createNewAnnotation:(CLLocationCoordinate2D)coordinate {
    MapAnnotation *annotation = [[MapAnnotation alloc] init];
    annotation.title = self.address.title ? self.address.title : @"Title";
    annotation.subtitle = @"";
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
}

- (void)creareAnnotation:(CLLocationCoordinate2D)coordinate {
    
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    
    if ((coordinate.latitude == 0) && (coordinate.longitude == 0)) {
        [self createAnnotationFromAddress];
    }
    else {
        [self createAnnotationFromLocation];
    }
    self.pinWillAppeared = NO;
}

- (void)createAnnotationFromLocation {
    __weak MapViewController *weakSelf = self;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.address.latitude
                                                      longitude:self.address.longitude];
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            return;
        }
        if (placemarks && placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            [weakSelf initializationAnnotation:placemark];
        }
    }];
}

- (void)createAnnotationFromAddress {
    __weak MapViewController *weakSelf = self;
    NSString *addressString = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@", self.address.thoroughfare, self.address.subLocality, self.address.locality, self.address.subAdministrativeArea, self.address.administrativeArea, self.address.postalCode, self.address.country, self.address.ISOcountryCode];
    
    [self.geoCoder geocodeAddressString:addressString
                      completionHandler:^(NSArray *placemarks, NSError *error) {
                          
                          if (error) {
                              self.pinWillAppeared = YES;
                              return;
                          }
                          if (placemarks && placemarks.count > 0) {
                              CLPlacemark *placemark = [placemarks objectAtIndex:0];
                              [weakSelf initializationAnnotation:placemark];
                          }
                      }];
}

- (void)initializationAnnotation:(CLPlacemark *)placemark {
    CLLocation *location = placemark.location;
    MapAnnotation *annotation = [[MapAnnotation alloc] init];
    CLLocationCoordinate2D coordinate = location.coordinate;
    annotation.title = self.address.title ? self.address.title : @"Title";
    annotation.subtitle = @"";
    annotation.coordinate = coordinate;
    MKCoordinateRegion region = self.mapView.region;
    region.center = [(CLCircularRegion *)placemark.region center];;
    region.span.longitudeDelta /= 8.0;
    region.span.latitudeDelta /= 8.0;
    
    [self.mapView setRegion:region animated:YES];
    [self.mapView addAnnotation:annotation];
}

- (void)showAlertWithTitle:(NSString*) title andMessage:(NSString*) message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)actionDescription:(UIButton *)sender {
    
    MKAnnotationView* annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    
    [self.geoCoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray *placemarks, NSError *error) {
         NSString *message = nil;
         if (error) {
             return;
         }
         else {
             if ([placemarks count] > 0) {
                 MKPlacemark *placemark = [placemarks firstObject];
                 message = [NSString stringWithFormat:@"Country = %@", placemark.country];
             }
             else {
                 message = @"No Placemarks Found";
             }
         }
         [self showAlertWithTitle:@"Location" andMessage:message];
     }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString* identifier = @"Annotation";
    MKPinAnnotationView* pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
        
        UIButton* descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [descriptionButton addTarget:self
                              action:@selector(actionDescription:)
                    forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = descriptionButton;
    }
    else {
        pin.annotation = annotation;
    }
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateEnding) {
        CLLocationCoordinate2D location = view.annotation.coordinate;
        self.address.latitude = location.latitude;
        self.address.longitude = location.longitude;
    }
}


@end
