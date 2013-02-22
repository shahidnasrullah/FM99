//
//  SteamValidator.h
//  FmTestApp
//
//  Created by coeus on 20/02/2013.
//  Copyright (c) 2013 coeus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SteamValidator : NSObject <NSStreamDelegate>
{
    NSURL * requestURL;
    NSMutableData * responseData;
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}

-(id) initWithUrl:(NSURL *)url;

@end
