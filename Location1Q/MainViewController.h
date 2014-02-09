//
//  MainViewController.h
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UIViewController<CLLocationManagerDelegate>

@property IBOutlet UIButton* btnPing;
@property IBOutlet UITextField* txtLocation;

+ (NSString*) siteUrl;

@end
