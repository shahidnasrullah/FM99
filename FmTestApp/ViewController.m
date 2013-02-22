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
@synthesize playButton, imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addDefaultStreamingURL];
    [self addVolumeView];
    currentTime = [NSNumber numberWithInt:0];
    timeElasped = 0;
    loader = nil;
    [self createAutioPlayer];
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    NSLog(@"Height: %f", screenRect.size.height);
    if (screenRect.size.height > 480)
    {
        // IPHONE_5 SPECIFIC
        self.imageView.image = [UIImage imageNamed:@"Default-568h@2x.png"];
    }
    else
    {
        // IPHONE_4 SPECIFIC
        self.imageView.image = [UIImage imageNamed:@"Default@2x.png"];
        [playButton setFrame:CGRectMake(playButton.frame.origin.x + 4, playButton.frame.origin.y, playButton.frame.size.width - 8, playButton.frame.size.height)];
    }
}

-(void) addDefaultStreamingURL
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * url_stream = [defaults objectForKey:@"streamURL"];
    if(url_stream == nil)
    {
        [defaults setObject:kRadioStreamURL forKey:@"streamURL"];
    }
}


-(void) addVolumeView
{
    self.tempView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, self.tempView.frame.size.width, self.tempView.frame.size.height)];
    [self.tempView addSubview:volumeView];;
	
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
    AVPlayerItem * item = [audioPlayer currentItem];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * url = [defaults objectForKey:@"streamURL"];
    NSLog(@"URL: %@", url);
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:url] options:nil];
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

-(void) startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}

-(void) stopTimer
{
    [timer invalidate];
    timeElasped = 0;
    [self removeActivityIndicator];
}

-(void) timerTick
{
    NSNumber * playbackTime = [NSNumber numberWithLongLong:[audioPlayer currentTime].value/[audioPlayer currentTime].timescale];
    if([currentTime isEqualToNumber:playbackTime])
    {
        timeElasped++;
        if(loader == nil){
            [self createActivityIndicator];
        }
        if (timeElasped>30) {
            
            //NSLog(@"URL is invalid Load other url");
        }
        //NSLog(@"Equal");
    }
    else
    {
        timeElasped = 0;
        currentTime = playbackTime;
        [self removeActivityIndicator];
    }
    //NSLog(@"Time Elapsed: %d", timeElasped);
    //NSLog(@"Playback time: %lld", [audioPlayer currentTime].value/[audioPlayer currentTime].timescale);
}

-(void) createActivityIndicator
{
    NSArray * nibsArray = [[NSBundle mainBundle] loadNibNamed:@"Loader" owner:nil options:nil];
    loader = [nibsArray objectAtIndex:0];
    [loader autoPosition:self.view.frame];
    [loader startAnimating];
    [self.view addSubview:loader];
}

-(void) removeActivityIndicator
{
    [loader removeFromSuperview];
    loader = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"status"])
    {
        NSLog(@"Observer Called");
        if([audioPlayer status] == AVPlayerStatusFailed)
        {
            NSLog(@"Status Failed");
        }
        else if ([audioPlayer status] == AVPlayerStatusReadyToPlay)
        {
            NSLog(@"Ready to Play");
        }
        else if([audioPlayer status] == AVPlayerStatusUnknown)
        {
            NSLog(@"Unknow status");
        }
    }
    else
    {
        NSLog(@"Observer path is invalid");
    }
}

-(void)streamAudio:(id)sender
{
    if(!isPlaying){
        isPlaying = YES;
        [self changeStramingURL];
        [audioPlayer play];
        [playButton setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
        [self startBackgroundService];
        [self startTimer];
    }
    else
    {
        [audioPlayer pause];
        isPlaying = NO;
        [playButton setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
        [self endBackgroundService];
        [self stopTimer];
    }
}

-(void) changeStramingURL
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * newURL = [defaults objectForKey:@"streamURL"];
    if(streamingURL != nil && ![streamingURL isEqualToString:newURL])
    {
        streamingURL = newURL;
        AVPlayerItem * newItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:streamingURL]];
        [audioPlayer replaceCurrentItemWithPlayerItem:newItem];
    }
}

-(void) startBackgroundService
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            /* just fail if this happens. */
            NSLog(@"BackgroundTask Expiration Handler is called");
            [self endBackgroundService];
        }];
    }
}

-(void) endBackgroundService
{
    if (backgroundTask) {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
    }

}

-(void) createAutioPlayer
{
    if(!audioPlayer)
    {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        streamingURL = [defaults objectForKey:@"streamURL"];
        //NSLog(@"URL: %@", streamingURL);
        audioPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:streamingURL]];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
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

- (void)viewDidUnload {
    [self setVoluemView:nil];
    [self setTempView:nil];
    [super viewDidUnload];
}

@end
