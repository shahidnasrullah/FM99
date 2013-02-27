//
//  ViewController.h
//  FmTestApp
//
//  Created by coeus on 12/02/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Loader.h"

# define firstURL @"http://tamilmurasam.serveftp.com:8000/"
# define secondURL @"http://stream.radionova.no/fm993.mp3.m3u"

# define kRealURL @"http://tamilmurasam.serveftp.com:8000/"
# define kRadioStreamURL @"http://stream.radionova.no/fm993.mp3.m3u"

@interface ViewController : UIViewController
{
	NSTimer *progressUpdateTimer;
    BOOL isPlaying;
    BOOL isFirstPlaying;
    AVPlayer * audioPlayer;
    UIBackgroundTaskIdentifier backgroundTask;
    NSTimer * timer;
    NSNumber * currentTime;
    int timeElasped;
    Loader * loader;
    NSString * streamingURL;
}
@property (weak, nonatomic) IBOutlet UIView *tempView;
@property (weak, nonatomic) IBOutlet UISlider *voluemView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton * playButton;

-(IBAction)streamAudio:(id)sender;
-(IBAction)sliderChanged:(id)sender;
-(IBAction)openFacebookLink:(id)sender;
-(IBAction)openContectLink:(id)sender;

@end
