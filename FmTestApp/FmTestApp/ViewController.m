//
//  ViewController.m
//  FmTestApp
//
//  Created by coeus on 12/02/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import "ViewController.h"

#import "FacebookViewController.h"
#import "ContactViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize playButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self createAutioPlayer];
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    NSLog(@"Height: %f", screenRect.size.height);
    if (screenRect.size.height >= 548)
    {
        NSLog(@"iphone 5");
    }
    else
    {
        NSLog(@"iphone 4");
        [playButton setFrame:CGRectMake(playButton.frame.origin.x + 4, playButton.frame.origin.y, playButton.frame.size.width - 8, playButton.frame.size.height)];
        
    }
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sliderChanged:(id)sender
{
    UISlider * slider = (UISlider*) sender;
    [self performSelectorInBackground:@selector(changeVolume:) withObject:[NSNumber numberWithFloat:slider.value]];
}

-(void) changeVolume:(id) volume
{
    NSNumber * num = (NSNumber*) volume;
    /*MPMusicPlayerController * musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
     musicPlayer.volume = slider.value;*/
    AVPlayerItem * item = [audioPlayer currentItem];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:kRadioStreamURL] options:nil];
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:[num floatValue] atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    [item setAudioMix:audioMix];
}


-(void)streamAudio:(id)sender
{
    if(!isPlaying){
        isPlaying = YES;
        [audioPlayer play];
        [playButton setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
    }
    else
    {
        [audioPlayer pause];
        isPlaying = NO;
        [playButton setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
    }
}

-(void) createAutioPlayer
{
    if(!audioPlayer)
    {
        audioPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:kRadioStreamURL]];
    }
}

-(void)openFacebookLink:(id)sender
{
    FacebookViewController * fbController = [[FacebookViewController alloc] initWithNibName:@"FacebookViewController" bundle:nil];
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:fbController];
    [self presentViewController:navController animated:YES completion:^{
    }];
}

-(void)openContectLink:(id)sender
{
    ContactViewController * contactController = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
    [self presentViewController:contactController animated:YES completion:^{
    }];
}

@end
