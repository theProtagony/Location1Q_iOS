//
//  MainViewController.h
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

// The main view controller for this app.
@interface MainViewController : UIViewController<CLLocationManagerDelegate>

@property IBOutlet UIButton* btnPing;           // Button to create a single location hit.
@property IBOutlet UIButton* btnTrack;           // Button to track the user (Standard)
@property IBOutlet UITextField* txtLocation;    // Text field to display current location.

+ (NSString*) siteUrl;                          // Static utility to control the main url of the website.

@end
