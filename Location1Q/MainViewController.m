//
//  MainViewController.m
//

#import "MainViewController.h"
#import "PDKeychainBindings.h"
#import "AFNetworking.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    
    NSMutableArray * jsonArray;

    
    NSString * storedUserId;
    NSString * storedAuthToken;
    
    UIActivityIndicatorView * busyIndicator;
    
    CLLocationManager * locationManager;
}


- (void)awakeFromNib
{
    
    [super awakeFromNib];
    
}

- (void) clearCredentials
{
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:@"userId"];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:@"authToken"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    if(![self verifyCredentials])
    {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }

    if(self.btnPing)
    {
        [self.btnPing addTarget:self action:@selector(pingMe) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) verifyCredentials
{
    storedUserId = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"userId"];
    storedAuthToken = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"authToken"];
    
    if(storedUserId != nil && storedAuthToken != nil)
        return YES;
    
    return NO;
}

- (void) pingMe
{
    NSLog(@"Ping Me!");
    
    if(!busyIndicator)
    {
        busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        busyIndicator.center = self.view.center;
        [busyIndicator setColor:[UIColor blackColor]];
        [self.view addSubview:busyIndicator];
    }
    
    [self.btnPing setEnabled:NO];
    [busyIndicator startAnimating];
    [self startStandardUpdates];
    
}

- (void) pingCompleted
{
    if(busyIndicator)
    {
        [busyIndicator stopAnimating];
        [self.btnPing setEnabled:YES];
    }
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
    {
        locationManager = [[CLLocationManager alloc] init];
    
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
        // Set a movement threshold for new events.
        locationManager.distanceFilter = 500; // meters
    
    }
    [locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{

    // Take the last location.
    CLLocation* location = [locations lastObject];
    
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0)
    {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        
        // Display in text.
        if(self.txtLocation)
        {
            self.txtLocation.text = [NSString stringWithFormat:@"Lat: %+.4f, Long: %+.4f", location.coordinate.latitude, location.coordinate.longitude];
        }
        
        // Send this location to the API.
        [self sendLocationToApi:location.coordinate];
        
    }
    
    [locationManager stopUpdatingLocation];
    [self pingCompleted];
    
}

- (void) sendLocationToApi:(CLLocationCoordinate2D) location
{
    // Receive auth token from API, store it.
    NSString* apiString = [NSString stringWithFormat:@"%@user/%@/location", [MainViewController siteUrl], storedUserId];
    
    NSDictionary * locationJSON = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithDouble:location.latitude], @"latitude",
                               [NSNumber numberWithDouble:location.longitude], @"longitude",
                               nil];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    // API Authentication token.
    [manager.requestSerializer setValue:storedAuthToken forHTTPHeaderField:@"Auth-Token"];
    
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    [manager POST:apiString parameters:locationJSON success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Returns: %@", responseObject);
        
        [self.btnPing setTitle:@"Success" forState:UIControlStateNormal];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);

        [self.btnPing setTitle:@"Try Again" forState:UIControlStateNormal];
        
    }];

}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Update failed!");
    [self pingCompleted];
    [self.btnPing setTitle:@"Try Again" forState:UIControlStateNormal];
}

+ (NSString*) siteUrl
{
    return @"http://test.1q.com/";
}

@end
