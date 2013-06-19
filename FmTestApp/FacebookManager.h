//
//  FacebookManager.h
//  MenuSpring
//
//  Created by Yasir Ali on 3/16/11.
//  Copyright 2011 VeriQual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

@protocol FacebookManagerDelegate;

@interface FacebookManager : NSObject <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>	{
	
	id <FacebookManagerDelegate> delegate;
	
	Facebook *facebook;
	NSArray *permissions;
	NSDictionary *personalInfo;
	
	BOOL isLoggedIn;
}

@property (nonatomic, assign) id <FacebookManagerDelegate> delegate;
@property (nonatomic, readonly) BOOL isLoggedIn;

- (void)loginFacebook;
- (void)logoutFacebook;

- (void)publishStreamWithInputDialogBox;
- (void)publishStream:(NSString*)statusText;
- (void)publishStream:(NSString*)statusText withLinkURL:(NSString*)urlString;
- (void)publishStream:(NSString*)statusText withAlbumImage:(UIImage*)image;
- (void)publishStream:(NSString*)statusText withAlbumImageFromURL:(NSString*)urlString;
- (void)publishLink:(NSString*)urlString;
- (void)publishAlbumImage:(UIImage*)image;
- (void)publishAlbumImageFromURL:(NSString*)urlString;

@end

@protocol FacebookManagerDelegate <NSObject>
@optional
- (void)manager:(FacebookManager*)manager facebookDidLogin:(BOOL)status;
- (void)manager:(FacebookManager*)manager facebookDidLogout:(BOOL)status;
- (void)manager:(FacebookManager*)manager facebookDidUpdate:(BOOL)status;
- (void)manager:(FacebookManager*)manager facebookDidReceivedError:(NSError*)error;

- (void)manager:(FacebookManager*)manager dialodLoadingDidFailWithError:(NSError*)error;
- (void)manager:(FacebookManager*)manager dialogDidSucceed:(BOOL)status;
- (void)manager:(FacebookManager*)manager dialogWillSucceed:(BOOL)status withURL:(NSURL*)url;
- (BOOL)manager:(FacebookManager*)manager externalBrowserShouldOpenURL:(NSURL*)url;
@end