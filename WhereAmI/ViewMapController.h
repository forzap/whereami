//
//  ViewMapController.h
//  WhereAmI
//
//  Created by Forza on 25/07/2020.
//  Copyright © 2020 Forza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewMapController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    __weak IBOutlet MKMapView *mapView;
    
    CLLocation *currentLocation;
}

- (IBAction)btnStartActivityClick:(id)sender;

@property (nonatomic,strong)CLLocationManager * locationManager;

@end /* ViewMapController_h */
