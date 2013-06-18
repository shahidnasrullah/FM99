//
//  RecordedTracksViewController.m
//  FmTestApp
//
//  Created by Adil Soomro on 18/06/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import "RecordedTracksViewController.h"
#import "PlayRecordingViewController.h"

@interface RecordedTracksViewController ()

@end

@implementation RecordedTracksViewController

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
    self.title = @"Recorded Tracks";
    dataArray = [[NSMutableArray alloc] init];
    app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self getListOfTracks];
    
    done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(barItemClicked:)];
    edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(barItemClicked:)];
    self.navigationItem.rightBarButtonItem = edit;
}

-(void) barItemClicked:(id) sender
{
    if([sender isKindOfClass:[UIBarButtonItem class]] &&[sender isEqual:edit])
    {
        isEditing = YES;
        [self.mTableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem = done;
    }
    else
    {
        isEditing = NO;
        [self.mTableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = edit;
    }
}

-(void) getListOfTracks
{
    NSString * documentPath = [app getDocumentPath];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString * fileName = [directoryContent objectAtIndex:count];
        NSLog(@"Path Extension: %@", [fileName pathExtension]);
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        if([[fileName pathExtension] isEqualToString:@"mp3"])
        {
            [dataArray addObject:[directoryContent objectAtIndex:count]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMTableView:nil];
    [super viewDidUnload];
}

-(void) removeItemAtIndex:(int) index
{
    NSString * documentPath = [app getDocumentPath];
    NSString * filePath = [dataArray objectAtIndex:index];
    filePath = [documentPath stringByAppendingPathComponent:filePath];
    NSFileManager * fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:filePath])
    {
        NSError * error;
        [fm removeItemAtPath:filePath error:&error];
        if(error)
        {
            NSLog(@"Error: %@", error.debugDescription);
        }
    }
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

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Editing Ended");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self removeItemAtIndex:indexPath.row];
        [dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlayRecordingViewController * playController = [[PlayRecordingViewController alloc] init];
    playController.filePath = [dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:playController animated:YES];
}

@end
