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
#import "OptionsViewController.h"
#import "Reachability.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>


@interface ViewController ()

@end

@implementation ViewController
@synthesize playButton, imageView;


#pragma mark - Life Cycle Events

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self addDefaultStreamingURL];
    app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self addVolumeView];
    currentTime = [NSNumber numberWithInt:0];
    timeElasped = 0;
    isFirstPlaying = YES;
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

- (void)viewDidUnload {
    [self setVoluemView:nil];
    [self setTempView:nil];
    [super viewDidUnload];
}

#pragma mark - IBAction Events

- (IBAction)startRecording:(id)sender {
    if (isRecoding) {
        [conn cancel];
        [self showSaveFileDialog:@"Save file with name"];
    }
    else
    {
        NSURL * url = [NSURL URLWithString:@"http://stream.radionova.no:80/fm993.mp3"];
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
        conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if(conn)
        {
            streamData = [[NSMutableData alloc] init];
        }
    }
    
    isRecoding = !isRecoding;
}

-(IBAction)streamAudio:(id)sender
{
    if(!isPlaying){
        if([self isConnected])
        {
            isPlaying = YES;
            //[self changeStramingURL];
            [audioPlayer play];
            [playButton setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
            [self startBackgroundService];
            [self startTimer];
        }
        else
        {
            UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection found!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorAlert show];
        }
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

-(IBAction)openFacebookLink:(id)sender
{
    FacebookViewController * fbController = [[FacebookViewController alloc] initWithNibName:@"FacebookViewController" bundle:nil];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:fbController];
    [self presentViewController:navController animated:YES completion:^{
    }];
}

-(IBAction)openContectLink:(id)sender
{
    OptionsViewController * optController = [[OptionsViewController alloc] init];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:optController];
    [self presentViewController:navController animated:YES completion:^{
        
    }];
    
    /*
    ContactViewController * contactController = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
    [self presentViewController:contactController animated:YES completion:^{
    }];*/
}

#pragma mark - Player Events

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

- (BOOL) isConnected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
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
        if (timeElasped>10) {
            //NSLog(@"URL is invalid Load other url");
            if(isFirstPlaying)
            {
                isFirstPlaying = NO;
                NSLog(@"Value is changed");
                [self changeStramingURL];
            }
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



-(void) changeStramingURL
{
    [audioPlayer pause];
    AVPlayerItem * newItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:secondURL]];
    [audioPlayer replaceCurrentItemWithPlayerItem:newItem];
    [audioPlayer play];
    NSLog(@"Second URL: %@", secondURL);
    /*NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * newURL = [defaults objectForKey:@"streamURL"];
    if(streamingURL != nil && ![streamingURL isEqualToString:newURL])
    {
        streamingURL = newURL;
        AVPlayerItem * newItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:streamingURL]];
        [audioPlayer replaceCurrentItemWithPlayerItem:newItem];
    }*/
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
        audioPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:firstURL]];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
}


-(void) showSaveFileDialog:(NSString*) msg
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save File" message:[NSString stringWithFormat:@"%@\n\n\n",msg] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 80.0, 260.0, 25.0)];
    [myTextField setPlaceholder:@"Enter File Name"];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    [alert addSubview:myTextField];
    [alert show];
}

-(void) deleteTempFile
{
    NSString * path = [app getDocumentPath];
    NSString * filePath = [path stringByAppendingPathComponent:@"temp.mp3"];
    NSFileManager * fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:filePath])
    {
        NSError * error;
        [fm removeItemAtPath:filePath error:&error];
        if(error)
        {
            NSLog(@"File cannot be deleted");
        }
    }
}

-(void) saveFileWithName:(NSString *) fileName
{
    NSString * path = [app getDocumentPath];
    NSString * filePath = [path stringByAppendingPathComponent:@"temp.mp3"];
    NSFileManager * fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:filePath])
    {
        NSString * newFilePath = [path stringByAppendingPathComponent:fileName];
        newFilePath = [newFilePath stringByAppendingString:@".mp3"];
        NSError * error;
        if([fm fileExistsAtPath:newFilePath])
        {
            [self showSaveFileDialog:@"File already exist with this name"];
        }
        else
        {
            if ([fm moveItemAtPath:filePath toPath:newFilePath error:&error] != YES)
            {
                [app showAlert:@"Error!" withMessage:[error localizedDescription]];
                [self deleteTempFile];
            }
            else
            {
                [app showAlert:@"Success!" withMessage:@"File Saved Successfully!"];
                [self deleteTempFile];
            }
        }
    }
}


/*
-(NSString*) getDocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}
*/
#pragma mark - NSURLConnectionDelegate

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error.userInfo);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * path = [app getDocumentPath];
    path = [path stringByAppendingPathComponent:@"temp.mp3"];
    if(![fileManager fileExistsAtPath:path])
    {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }
    NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    [myHandle seekToEndOfFile];
    [myHandle writeData:data];
    [myHandle closeFile];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Finished Loading");
}
#pragma  mark - UIalertViewDelegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self saveFileWithName:[NSString stringWithFormat:@"FM99_%@",[NSDate date]]];
    }
    else if (buttonIndex == 1)
    {
        if(myTextField.text == @"")
        {
            [app showAlert:@"Error" withMessage:@"Please provide any name to save file"];
        }
        else{
            [self saveFileWithName:myTextField.text];
        }
    }
}


@end
