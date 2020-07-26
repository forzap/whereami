#import "ViewMapController.h"
#import "ActivityViewController.h"

@interface ViewMapController ()

@end

@implementation ViewMapController

#pragma mark View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the MKMapView
    [mapView setDelegate:self];
    [mapView setShowsUserLocation:YES];
    [mapView setMapType:MKMapTypeStandard];
    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    //Check if Location Services are enabled, then start updating location
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
    else {
        UIAlertController * alert = [UIAlertController
        alertControllerWithTitle:@""
                         message:@"Location Services not enabled"
                  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
        [alert addAction:okAction];
        [[[ViewMapController keyWindow] rootViewController] presentViewController:alert animated:YES completion:^{
        }];
    }
}

- (IBAction)btnStartActivityClick:(id)sender {
    [self performSegueWithIdentifier:@"viewMapToActivityView" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"viewMapToActivityView"])
    {
        ActivityViewController *vc = [segue destinationViewController];
        vc.latitude = currentLocation.coordinate.latitude;
        vc.longitude = currentLocation.coordinate.longitude;
    }
}


#pragma mark Location Manager and MKMapView

- (void)locationManager:(CLLocationManager *)manager
didUpdateLocations:(NSArray *)locations
{
    currentLocation = (CLLocation *)[locations lastObject];
}

-(void)locationManager:(CLLocationManager *)manager
didFinishDeferredUpdatesWithError:(NSError *)error {
    NSLog(@"Error with updating");
}

-(void)locationManager:(CLLocationManager *)manager
didFailWithError:(NSError *)error
{
    //Failed to recieve user's location
    NSLog(@"Failed to received user's location");
}

#pragma mark Others

+(UIWindow*)keyWindow {
    UIWindow *windowRoot = nil;
    NSArray *windows = [[UIApplication sharedApplication]windows];
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            windowRoot = window;
            break;
        }
    }
    return windowRoot;
}
    
@end
