//
//  PlayRecordingViewController.m
//  FmTestApp
//
//  Created by Adil Soomro on 18/06/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import "PlayRecordingViewController.h"

@interface PlayRecordingViewController ()

@end

@implementation PlayRecordingViewController

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
    app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [self createPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createPlayer
{
    NSString * fileUrl = [[app getDocumentPath] stringByAppendingPathComponent:self.filePath];
    NSURL * url = [NSURL fileURLWithPath:fileUrl];
    NSLog(@"File URL: %@", url);
    audioFile = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    audioFile.delegate = self;
    totalTime = audioFile.duration;
    [self.lblTotalTime setText:[NSString stringWithFormat:@"%f",totalTime]];
}




- (IBAction)playRecording:(id)sender {
    UIButton * btn = (UIButton*) sender;
    if (isPlaying) {
        [audioFile stop];
        [btn setTitle:@"Play" forState:UIControlStateNormal];
    }
    else
    {
        [audioFile play];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSTOP_PLAYING object:nil];
        [btn setTitle:@"Stop" forState:UIControlStateNormal];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    }
    isPlaying = !isPlaying;
}

-(void) timerTick
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.lblCurrentTime setText:[NSString stringWithFormat:@"%f",audioFile.currentTime]];
    });
}

- (void)viewDidUnload {
    [self setBtn:nil];
    [self setLblTotalTime:nil];
    [self setLblCurrentTime:nil];
    [super viewDidUnload];
}

#pragma mark - AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [audioFile stop];
    [_btn setTitle:@"Play" forState:UIControlStateNormal];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [app showAlert:@"Error" withMessage:@"Cannot play this file"];
}

@end
