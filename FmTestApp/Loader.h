//
//  Loader.h
//  ACS Cloud
//
//  Created by coeus on 15/02/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Loader.h"

@interface Loader : UIView
{
    UIActivityIndicatorView * actInd;
    UILabel * lbl_loading;
}

//@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * actInd;
//@property (nonatomic, retain) IBOutlet UILabel * lbl_loading;
- (id)initWithParent:(CGRect)parent;
-(void) startAnimating;
-(void) stopAnimating;
-(void) autoPosition:(CGRect) parent;

@end
