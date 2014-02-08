//
//  ListsViewController.m
//  TodoList
//
//  Created by Mitesh Shah on 12/12/13.
//  Copyright (c) 2013 Partly Crazy. All rights reserved.
//

#import "ListsViewController.h"
#import "PDKeychainBindings.h"
#import "AFNetworking.h"

@interface ListsViewController ()

@end

@implementation ListsViewController
{
    
    NSMutableArray * jsonArray;

    
    NSString * storedUserId;
    NSString * storedAuthToken;
}


- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
    
    //[[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:@"userName"];
    //[[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:@"userPass"];
    
    [self verifyCredentials];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    if(![self verifyCredentials])
    {
        [self performSegueWithIdentifier:@"LoginSegueLists" sender:self];
    }
    else
    {
    }
    
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self verifyCredentials])
    {
    }
}

- (void)stopRefresh
{
    
    [self.refreshControl endRefreshing];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!jsonArray)
        return 0;
    
    return [jsonArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    NSDictionary * objInfo = [jsonArray objectAtIndex:indexPath.row];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [objInfo valueForKey:@"title"];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     if (editingStyle == UITableViewCellEditingStyleDelete) {
     [_objects removeObjectAtIndex:indexPath.row];
     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     } else if (editingStyle == UITableViewCellEditingStyleInsert) {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
     }
     */
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Cancelled.
    if(buttonIndex == 0)
        return;

    
}


- (BOOL) verifyCredentials
{
    storedUserId = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"userId"];
    storedAuthToken = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"authToken"];
    
    if(storedUserId != nil && storedAuthToken != nil)
        return YES;
    
    return NO;
}

+ (NSString*) siteUrl
{
    return @"http://test.1q.com/";

}

@end
