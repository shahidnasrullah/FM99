//
//  ViewController.h
//  FmTestApp
//
//  Created by coeus on 12/02/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

# define kRadioStreamURL @"http://5163.live.streamtheworld.com/WEDRFM_SC"

@interface ViewController : UIViewController
{
	NSTimer *progressUpdateTimer;
    BOOL isPlaying;
    AVPlayer * audioPlayer;
}
@property (nonatomic, strong) IBOutlet UIButton * playButton;

-(IBAction)streamAudio:(id)sender;
-(IBAction)sliderChanged:(id)sender;
-(IBAction)openFacebookLink:(id)sender;
-(IBAction)openContectLink:(id)sender;

@end
