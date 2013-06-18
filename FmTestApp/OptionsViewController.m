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
            
            break;
        case ROW_TYPE_TWITTER:
            
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


@end
