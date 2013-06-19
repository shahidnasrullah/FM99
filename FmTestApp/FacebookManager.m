//
//  FacebookManager.m
//  MenuSpring
//
//  Created by Yasir Ali on 3/16/11.
//  Copyright 2011 VeriQual. All rights reserved.
//

#import "FacebookManager.h"
#import "SBJSON.h"
//#import "PaintColorChooseAppDelegate.h"

#define kApplicationID		@"355217071199637"
#define kApplicationSecret	@"904dba538b47f5f74f7a8268161581f8"

//#define kApplicationID		@"192723860776077"
//#define kApplicationSecret	@"487234d1c932bd83ecdb8943983036fd"

#define kTitleName			NSLocalizedString(@"Whiteboard Mojo", @"Application Title.")
#define kCaption			NSLocalizedString(@"Reference Documentation", @"Application Title.")
#define kDescription		NSLocalizedString(@"Dialogs provide a simple, consistent interface for apps to interact with users.", @"Application Title.")

@interface FacebookManager (Private)
- (void)getUserInfo;
@end

@implementation FacebookManager


@synthesize delegate;


- (id)init {
	if (self = [super init]) {
		isLoggedIn = NO;
		
		permissions = [[NSArray alloc] initWithObjects:@"read_stream", @"publish_stream",nil];
		facebook = [[Facebook alloc] initWithAppId:kApplicationID];
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AccessToken"] != nil)	{
			facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AccessToken"];
		}
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"] != nil)	{
			facebook.expirationDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
		}
		
		[self isLoggedIn];
		//[(PaintColorChooseAppDelegate *)[[UIApplication sharedApplication] delegate] setFacebook:facebook];
	}
	return self;
}

- (void) dealloc {
	[personalInfo release];
	[facebook release];
	[permissions release];
	[super dealloc];
}


- (BOOL)isLoggedIn	{
	isLoggedIn = [facebook isSessionValid];
	return isLoggedIn;
}

- (void)loginFacebook	{
	[facebook authorize:permissions delegate:self];
}

- (void)logoutFacebook	{
	[facebook logout:self];
}

- (void)getUserInfo	{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"SELECT uid, name, pic FROM user WHERE uid = me() ", @"query", nil];
	
	[facebook requestWithMethodName:@"fql.query"	//@"facebook.fql.query"
						  andParams:params
					  andHttpMethod:@"POST"
						andDelegate:self];
}

- (void)publishStreamWithInputDialogBox {
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSDictionary *actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
														   @"Always Running", @"text", @"http://itsti.me/", @"href", nil], nil];
	
	NSString *actionLinksString = [jsonWriter stringWithObject:actionLinks];
	NSDictionary *attachment = [NSDictionary dictionaryWithObjectsAndKeys:
								kTitleName, @"name",
								kCaption, @"caption",
								kDescription, @"description",
								@"http://itsti.me/", @"href", nil];
	
	NSString *attachmentString = [jsonWriter stringWithObject:attachment];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   kApplicationID, @"api_key",
								   @"Share on Facebook",  @"user_message_prompt",
								   actionLinksString, @"action_links",
								   attachmentString, @"attachment", nil];
	
	[facebook dialog:@"stream.publish" andParams:params andDelegate:self];
}

- (void)publishStream:(NSString*)statusText {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   statusText, @"message", nil];
	
	[facebook requestWithGraphPath:@"feed" 
						 andParams:params
					 andHttpMethod:@"POST" 
					   andDelegate:self];
}

- (void)publishStream:(NSString*)statusText withLinkURL:(NSString*)urlString {
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   kApplicationID, @"app_id",
								   @"http://developers.facebook.com/docs/reference/dialogs/", @"link",
								   urlString, @"picture",
								   kTitleName, @"name",
								   kCaption, @"caption",
								   kDescription, @"description",
								   statusText,  @"message", nil];
	
	[facebook dialog:@"feed" andParams:params andDelegate:self];
}

- (void)publishStream:(NSString*)statusText withAlbumImage:(UIImage*)image; {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   image, @"picture", statusText, @"message", nil];
	
	[facebook requestWithGraphPath:@"/me/photos" 
						 andParams:params
					 andHttpMethod:@"POST" 
					   andDelegate:self];
}

- (void)publishStream:(NSString*)statusText withAlbumImageFromURL:(NSString*)urlString {
	NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
	UIImage *image  = [[UIImage alloc] initWithData:imageData];
	[self publishStream:statusText withAlbumImage:image];
	[image release];
}

- (void)publishLink:(NSString*)urlString {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"http://developers.facebook.com/docs/reference/dialogs/", @"link",
								   urlString, @"picture",
								   kTitleName, @"name",
								   kCaption, @"caption",
								   kDescription, @"description", nil];
	
	[facebook requestWithGraphPath:@"feed" 
						 andParams:params
					 andHttpMethod:@"POST" 
					   andDelegate:self];
}

- (void)publishAlbumImage:(UIImage*)image {
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, @"picture", nil];
	
	[facebook requestWithMethodName:@"photos.upload"
						   andParams:params
					   andHttpMethod:@"POST"
						 andDelegate:self];
}

- (void)publishAlbumImageFromURL:(NSString*)urlString {
	NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
	UIImage *image  = [[UIImage alloc] initWithData:imageData];
	[self publishAlbumImage:image];
	[image release];
}


#pragma mark -
#pragma mark FBSessionDelegate

- (void)fbDidLogin	{
	[[NSUserDefaults standardUserDefaults] setObject:facebook.accessToken forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:facebook.expirationDate forKey:@"ExpirationDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	
	[self getUserInfo];
	if ([self.delegate respondsToSelector:@selector(manager:facebookDidLogin:)])
		[self.delegate manager:self facebookDidLogin:YES];
}

- (void)fbDidNotLogin:(BOOL)cancelled	{
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ExpirationDate"];
	if ([self.delegate respondsToSelector:@selector(manager:facebookDidLogin:)])
		[self.delegate manager:self facebookDidLogin:NO];
}

- (void)fbDidLogout	{
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ExpirationDate"];
	if ([self.delegate respondsToSelector:@selector(manager:facebookDidLogout:)])
		[self.delegate manager:self facebookDidLogout:YES];
}


#pragma mark FBRequestDelegate

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    ALog(@"request:didReceiveResponse:");
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	personalInfo = [[NSDictionary alloc] initWithDictionary:result];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    ALog(@"request:didFailWithError:");
	if ([self.delegate respondsToSelector:@selector(manager:facebookDidReceivedError:)])
		[self.delegate manager:self facebookDidReceivedError:error];
}


#pragma mark FBDialogDelegate
// Called when the dialog succeeds and is about to be dismissed.
- (void)dialogDidComplete:(FBDialog *)dialog {
	ALog(@"dialogDidComplete:"); // after call dialogCompleteWithUrl delegate method
	if ([self.delegate respondsToSelector:@selector(manager:dialogDidSucceed:)])
		[self.delegate manager:self dialogDidSucceed:YES];
}
// Called when the dialog succeeds with a returning url.
- (void)dialogCompleteWithUrl:(NSURL *)url {
	ALog(@"dialogCompleteWithUrl:"); // direct call after publish stream.
	if ([self.delegate respondsToSelector:@selector(manager:dialogWillSucceed:withURL:)])
		[self.delegate manager:self dialogWillSucceed:YES withURL:url];
}
// Called when the dialog get canceled by the user.
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url {
	ALog(@"dialogDidNotCompleteWithUrl:");
	if ([self.delegate respondsToSelector:@selector(manager:dialogWillSucceed:withURL:)])
		[self.delegate manager:self dialogWillSucceed:NO withURL:url];
}

// Called when the dialog is cancelled and is about to be dismissed.
- (void)dialogDidNotComplete:(FBDialog *)dialog {
	ALog(@"dialogDidNotComplete:");
	if ([self.delegate respondsToSelector:@selector(manager:dialogDidSucceed:)])
		[self.delegate manager:self dialogDidSucceed:NO];
}
// Called when dialog failed to load due to an error.
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
	ALog(@"dialog:didFailWithError:");
	if ([self.delegate respondsToSelector:@selector(manager:dialodLoadingDidFailWithError:)])
		[self.delegate manager:self dialodLoadingDidFailWithError:error];
}
/**
 * Asks if a link touched by a user should be opened in an external browser.
 * If a user touches a link, the default behavior is to open the link in the Safari browser, which will cause your app to quit.  You may want to prevent this from happening, open the link in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you should hold onto the URL and once you have received their acknowledgement open the URL yourself using [[UIApplication sharedApplication] openURL:].
**/
- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url {
	ALog(@"dialog:shouldOpenURLInExternalBrowser:");
	if ([self.delegate respondsToSelector:@selector(manager:externalBrowserShouldOpenURL:)])
		return [self.delegate manager:self externalBrowserShouldOpenURL:url];
	else
		return YES;
}


@end
