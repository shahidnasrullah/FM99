//
//  OptionsViewController.h
//  FmTestApp
//
//  Created by Adil Soomro on 18/06/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookManager.h"

typedef enum {
    ROW_TYPE_RECORDING,
    ROW_TYPE_FACEBOOK,
    ROW_TYPE_TWITTER,
    ROW_TYPE_CONTACTS
    
} ROW_TYPE;

@interface OptionsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FacebookManagerDelegate>
{
    NSMutableArray * dataArray;
    FacebookManager *fbManager;
}
@property (weak, nonatomic) IBOutlet UITableView *mTableView;


@end
