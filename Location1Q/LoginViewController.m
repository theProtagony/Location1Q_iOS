//
//  LoginViewController.m
//  TodoList
//
//  Created by Mitesh Shah on 12/4/13.
//  Copyright (c) 2013 Partly Crazy. All rights reserved.
//

#import "LoginViewController.h"
#import "PDKeychainBindings.h"
#import "AFNetworking.h"

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
    NSString* apiString = @"http://test.1q.com/user/authenticate";
    
    NSDictionary * userJSON = [[NSDictionary alloc] initWithObjectsAndKeys:
                               self.userName.text, @"username",
                               self.userPass.text, @"password",
                                  nil];
    
    
    NSLog(@"Connecting with %@", userJSON);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    [manager POST:apiString parameters:userJSON success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Returns: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];

}

@end
