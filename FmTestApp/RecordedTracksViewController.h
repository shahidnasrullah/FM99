//
//  RecordedTracksViewController.h
//  FmTestApp
//
//  Created by Adil Soomro on 18/06/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RecordedTracksViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * dataArray;
    AppDelegate * app;
    UIBarButtonItem * done;
    UIBarButtonItem * edit;
    BOOL isEditing;
}
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@end
