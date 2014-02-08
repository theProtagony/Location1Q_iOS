//
//  LoginViewController.m
//

#import "LoginViewController.h"
#import "PDKeychainBindings.h"
#import "AFNetworking.h"
#include "MainViewController.h"


@interface LoginViewController ()
{
    NSString * strUser;
    NSString * strPass;
    NSString * strAuthToken;
}

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if([self btnLogin] != nil)
    {
        [[self btnLogin] addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginClick:(id) info
{
    // Receive auth token from API, store it.
    NSString* apiString = [NSString stringWithFormat:@"%@user/authenticate/", [MainViewController siteUrl]];
    
    NSDictionary * userJSON = [[NSDictionary alloc] initWithObjectsAndKeys:
                               self.userName.text, @"username",
                               self.userPass.text, @"password",
                                  nil];
    
    
    NSLog(@"Connecting with %@", userJSON);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];

    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.userName.text password:self.userPass.text];
    
    [manager POST:apiString parameters:userJSON success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Returns: %@", responseObject);
        
        if(responseObject != nil)
        {
            // Save the "_id" and "Auth-Token";
            if([responseObject objectForKey:@"_id"])
            {
                [[PDKeychainBindings sharedKeychainBindings] setObject:[responseObject objectForKey:@"_id"] forKey:@"userId"];
            }
            
            if([responseObject objectForKey:@"Auth-Token"])
            {
                [[PDKeychainBindings sharedKeychainBindings] setObject:[responseObject objectForKey:@"Auth-Token"] forKey:@"authToken"];
                
            }
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                        message:@"Please check your username and password."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];

}

@end
