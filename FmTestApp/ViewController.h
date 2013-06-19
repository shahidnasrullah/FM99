//
//  ViewController.h
//  FmTestApp
//
//  Created by coeus on 12/02/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

#import "Loader.h"

# define firstURL @"http://tamilmurasam.serveftp.com:8000/uip"
# define secondURL @"http://stream.radionova.no/fm993.mp3.m3u"

# define kfirstRecordingURL @"http://tamilmurasam.serveftp.com:8000/"
# define kSecondRecordingURL @"http://stream.radionova.no/fm993.mp3"

@interface ViewController : UIViewController<NSURLConnectionDelegate, UIAlertViewDelegate>
{
	NSTimer *progressUpdateTimer;
    BOOL isPlaying;
    BOOL isFirstPlaying;
    BOOL isRecoding;
    AVPlayer * audioPlayer;
    UIBackgroundTaskIdentifier backgroundTask;
    NSTimer * timer;
    NSNumber * currentTime;
    int timeElasped;
    Loader * loader;
    NSString * streamingURL;
    NSMutableData * streamData;
    UITextField *myTextField;
    NSURLConnection * conn;
    AppDelegate * app;
    AVPlayerItem * currentItem;
    NSString * currentPlayingURL;
}
- (IBAction)startRecording:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *tempView;
@property (weak, nonatomic) IBOutlet UISlider *voluemView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton * playButton;

-(IBAction)streamAudio:(id)sender;
-(IBAction)sliderChanged:(id)sender;
-(IBAction)openFacebookLink:(id)sender;
-(IBAction)openContectLink:(id)sender;

@end
