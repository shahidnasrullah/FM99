//
//  PlayRecordingViewController.m
//  FmTestApp
//
//  Created by Adil Soomro on 18/06/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import "PlayRecordingViewController.h"
#import <MediaPlayer/MediaPlayer.h>

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
    self.title = @"Play";
    [self.mFileName setText:self.filePath];
    [self.lblCurrentTime setText:@"00H:00M:00S"];
    app = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [self createPlayer];
    [self addVolumeView];
    [self setProgressSlider];
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
    [self.lblTotalTime setText:[self foramatTime:totalTime]];
}

-(NSString*) foramatTime:(double) seconds
{
    int hours = seconds / 3600;
    seconds = fmod(seconds, 3600);
    int mints = seconds / 60;
    seconds = fmod(seconds, 60);
    NSString * s = [NSString stringWithFormat:@"%2.0dH:%2.0dM:%2.0fS", hours, mints,seconds];
    return s;
}

-(void) setProgressSlider
{
    [self.timeLineSlider setMinimumValue:0];
    [self.timeLineSlider setMaximumValue:audioFile.duration];
}


- (IBAction)playRecording:(id)sender {
    if (isPlaying) {
        [self pause];
    }
    else
    {
        [self play];
    }
    isPlaying = !isPlaying;
}

-(void) play
{
    [audioFile play];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSTOP_PLAYING object:nil];
    //[_btn setTitle:@"Stop" forState:UIControlStateNormal];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    [_btn setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
}

-(void)pause
{
    [audioFile stop];
    //[timer invalidate];
    [_btn setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
}

-(void) timerTick
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.lblCurrentTime setText:[self foramatTime:audioFile.currentTime]];
        [self.timeLineSlider setValue:[audioFile currentTime]];
    });
}

-(void) addVolumeView
{
    self.tempView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, self.tempView.frame.size.width, self.tempView.frame.size.height)];
    [self.tempView addSubview:volumeView];
	
}

- (void)viewDidUnload {
    [timer invalidate];
    [self setBtn:nil];
    [self setLblTotalTime:nil];
    [self setLblCurrentTime:nil];
    [self setTempView:nil];
    [self setTimeLineSlider:nil];
    [self setMFileName:nil];
    [super viewDidUnload];
}

#pragma mark - AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self pause];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [app showAlert:@"Error" withMessage:@"Cannot play this file"];
}

@end
