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
    
    NSString * storedUserId;        // User ID for the API (store / retrieve from keychain)
    NSString * storedAuthToken;     // Authentication Token for the API (store / retrieve from keychain)
    
    UIActivityIndicatorView * busyIndicator;    // For longer operations, displays the spinner.
    
    CLLocationManager * locationManager;    // Works with the Location Framework to get the Longitude / Latitude.
    
    BOOL isTracking;        // One time or continuous?
    int  sendCount;         // How many sent to API during this tracking session..
    
    BOOL standardMethod;
}

// Utility function for testing. Removes stored data in keychain.
- (void) clearCredentials
{
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:@"userId"];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:@"authToken"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // If user credentials are not present, navigate to the login screen.
    if(![self verifyCredentials])
    {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    }

    // Setup the ping button to perform a one time location hit.
    if(self.btnPing)
    {
        [self.btnPing addTarget:self action:@selector(pingMe) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(self.btnTrack)
    {
        [self.btnTrack addTarget:self action:@selector(toggleTracking) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Retrieves the stored user authentication from keychain and returns boolean to indicate if they exist.
- (BOOL) verifyCredentials
{
    storedUserId = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"userId"];
    storedAuthToken = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"authToken"];
    
    if(storedUserId != nil && storedAuthToken != nil)
        return YES;
    
    return NO;
}

// Initiates a one time hit.
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
    
    [self disableButtons];
    [busyIndicator startAnimating];
    [self startStandardUpdates];
    
}

- (void) disableButtons
{
    if(self.btnPing)
    {
        [self.btnPing setEnabled:NO];
    }
    if (self.btnTrack)
    {
        [self.btnTrack setEnabled:NO];
    }
}

- (void) enableButtons
{
    if(self.btnPing)
    {
        [self.btnPing setEnabled:YES];
    }
    if (self.btnTrack)
    {
        [self.btnTrack setEnabled:YES];
    }
}

- (void) toggleTracking
{

    if(isTracking)
    {
        [locationManager stopUpdatingLocation];
        [locationManager stopMonitoringSignificantLocationChanges];
        
        [self.btnTrack setTitle:@"Track Me" forState:UIControlStateNormal];
        
        NSLog(@"Tracking Off.");
    }
    else
    {
        // Choose between high battery impact + high accuracy,
        // Or low battery impact + low accuracy.
//        [self startStandardUpdates];
        [self startSignificantChangeUpdates];
        isTracking = YES;
        sendCount = 0;
        [self.btnTrack setTitle:@"Stop" forState:UIControlStateNormal];
        NSLog(@"Tracking On.");
    }

}

// At the end of a one time hit.
- (void) pingCompleted
{
    NSLog(@"Ping Completed.");
    
    // Stop receiving updates.
    [locationManager stopUpdatingLocation];

    
    if(busyIndicator)
    {
        [busyIndicator stopAnimating];
        [self enableButtons];
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
        // Disable this when debugging location updates.
        locationManager.distanceFilter = 500; // meters
    
    }
    // Start receiving updates.
    [locationManager startUpdatingLocation];
}

- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
    }
    // Start receiving updates (low battery use).
    [locationManager startMonitoringSignificantLocationChanges];
    standardMethod = NO;
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{

    NSLog(@"Location Manager : didUpdateLocations");
    
    // Take the last location.
    CLLocation* location = [locations lastObject];
    
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (!isTracking || sendCount == 0 || abs(howRecent) < 15.0)
    {
        sendCount++;

        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f; count: %d\n",
              location.coordinate.latitude,
              location.coordinate.longitude, sendCount);
        
        // Display in text.
        if(self.txtLocation)
        {
            self.txtLocation.text = [NSString stringWithFormat:@"Lat: %+.4f, Long: %+.4f", location.coordinate.latitude, location.coordinate.longitude];
        }
        
        // Send this location to the API.
        [self sendLocationToApi:location.coordinate];
        
        
    }
    
    // Stop now if this is a ping.
    if(!isTracking)
    {
        [locationManager stopUpdatingLocation];
        [locationManager stopMonitoringSignificantLocationChanges];
        [self pingCompleted];
    }
    
}

// Sends a 2D location coordinate to the 1Q API.
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
//        NSLog(@"Returns: %@", responseObject);
        
        if(!isTracking)
        {
            [self.btnPing setTitle:@"Success" forState:UIControlStateNormal];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);

        if(!isTracking)
        {
            [self.btnPing setTitle:@"Try Again" forState:UIControlStateNormal];
        }
        
    }];

}

// Location manager failed to retrieve the location.
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
