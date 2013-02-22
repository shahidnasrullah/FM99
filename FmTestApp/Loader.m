//
//  Loader.m
//  ACS Cloud
//
//  Created by coeus on 15/02/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import "Loader.h"
#import <QuartzCore/QuartzCore.h>

@implementation Loader


- (id)initWithParent:(CGRect)parent
{
    NSArray * nibsArray = [[NSBundle mainBundle] loadNibNamed:@"Loader" owner:nil options:nil];
    self = [nibsArray objectAtIndex:0];
    actInd = (UIActivityIndicatorView*)[self viewWithTag:1];
    lbl_loading = (UILabel*)[self viewWithTag:2];
    if (self) {
        [self.layer setCornerRadius:5];
        [self setFrame:CGRectMake(parent.size.width/2 - self.frame.size.width/2, parent.size.height/2 - self.frame.size.height/2, self.frame.size.width, self.frame.size.height)];
    }
    return self;
}

-(void) startAnimating
{
    [actInd startAnimating];
}
-(void) stopAnimating
{
    [actInd stopAnimating];
}

-(void) autoPosition:(CGRect) parent
{
    [self.layer setCornerRadius:5];
    [self setFrame:CGRectMake(parent.size.width/2 - self.frame.size.width/2, parent.size.height/2 - self.frame.size.height/2, self.frame.size.width, self.frame.size.height)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
