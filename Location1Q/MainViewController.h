//
//  MainViewController.h
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UIViewController<CLLocationManagerDelegate>

@property IBOutlet UIButton* btnPing;

+ (NSString*) siteUrl;

@end
