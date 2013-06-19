//
//  OptionsViewController.m
//  FmTestApp
//
//  Created by Adil Soomro on 18/06/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import "OptionsViewController.h"
#import "ContactViewController.h"
#import "RecordedTracksViewController.h"
#import "MBProgressHUD.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface OptionsViewController ()

@end

@implementation OptionsViewController

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
    self.title = @"Options";
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeBarItemClicked:)];
    self.navigationItem.rightBarButtonItem = barItem;
    
    dataArray = [[NSMutableArray alloc] init];
    [dataArray addObject:@"Recorded Tracks"];
    [dataArray addObject:@"Share on Facebook"];
    [dataArray addObject:@"Share on Twitter"];
    [dataArray addObject:@"Contact Us"];
    
    fbManager = [[FacebookManager alloc] init];
    [fbManager setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) closeBarItemClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setMTableView:nil];
    [super viewDidUnload];
}

#pragma  mark - UITableView DataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [dataArray objectAtIndex:indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataArray count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case ROW_TYPE_RECORDING:
        {
            RecordedTracksViewController * trackController = [[RecordedTracksViewController alloc] init];
            [self.navigationController pushViewController:trackController animated:YES];
        }
            break;
        case ROW_TYPE_FACEBOOK:
        {
            if([fbManager isLoggedIn])
            {
                [fbManager publishStream:[NSString stringWithFormat:@"Listening %@ on FM99,3",[[NSUserDefaults standardUserDefaults] valueForKey:kItemTitle]]];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }
            else
            {
                [fbManager loginFacebook];
            }
        }
            break;
        case ROW_TYPE_TWITTER:
        {
            if ([TWTweetComposeViewController canSendTweet]) {
                
                TWTweetComposeViewController * tweetController = [[TWTweetComposeViewController alloc] init];
                [tweetController setInitialText:[NSString stringWithFormat:@"Listening %@",[[NSUserDefaults standardUserDefaults] valueForKey:kItemTitle]]];
                [self presentViewController:tweetController animated:YES completion:nil];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tamilmurasam"
                                                                message:@"No accounts configured! First Configure Twitter via iOS Settings"
                                                               delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }
            break;
        case ROW_TYPE_CONTACTS:
        {
            ContactViewController * contactController = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
            [self.navigationController pushViewController:contactController animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)manager:(FacebookManager*)manager facebookDidLogin:(BOOL)status
{
    if (status) {
        [fbManager publishStream:[NSString stringWithFormat:@"Listening %@ on FM99,3",[[NSUserDefaults standardUserDefaults] valueForKey:kItemTitle]]];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

- (void)manager:(FacebookManager*)manager facebookDidLogout:(BOOL)status
{
    
}

- (void)manager:(FacebookManager*)manager facebookDidUpdate:(BOOL)status
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (status) {
        NSLog(@"SUCCEEDED");
    }
    else
        NSLog(@"FAILED");
}

- (void)manager:(FacebookManager*)manager dialodLoadingDidFailWithError:(NSError*)error
{
    NSLog(@"Recieved Error %@",[error description]);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)manager:(FacebookManager*)manager dialogDidSucceed:(BOOL)status
{
    if (status) {
        NSLog(@"SUCCEEDED");
    }
    else
        NSLog(@"FAILED");
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)manager:(FacebookManager*)manager dialogWillSucceed:(BOOL)status withURL:(NSURL*)url
{
    if (status) {
        NSLog(@"Success with %@",url);
    }
    else
        NSLog(@"FAILED");
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)manager:(FacebookManager*)manager facebookDidReceivedError:(NSError*)error
{
    NSLog(@"Recieved Error %@",[error description]);
    if ([[[[error userInfo] valueForKey:@"error"] valueForKey:@"code"] integerValue] == 190) {
        [fbManager loginFacebook];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tamilmurasam" message:@"Error Occurred while sharing!"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert setCancelButtonIndex:0];
        [alert show];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


@end
