//
//  PlayRecordingViewController.h
//  FmTestApp
//
//  Created by Adil Soomro on 18/06/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface PlayRecordingViewController : UIViewController<AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioFile;
    BOOL isPlaying;
    AppDelegate * app;
    double  totalTime;
    NSTimer * timer;
}
@property (weak, nonatomic) IBOutlet UILabel *mFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalTime;
@property(nonatomic, retain) NSString * filePath;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UIView *tempView;
@property (weak, nonatomic) IBOutlet UISlider *timeLineSlider;

- (IBAction)playRecording:(id)sender;
@end
