//
//  QuestionList.m
//  karuta
//
//  Created by 荻原有二 on 2016/09/24.
//  Copyright © 2016年 Yuji Ogihara. All rights reserved.
//

#import "StationContent.h"


@implementation StationContent

- (id)init
{
    self = [super init];
    if(self) {
        // Initialize Queue
        self.object = NULL ;
        self.voice_data = NULL ;
    }
    return self;
}

- (void)dealloc {
    //    [super dealloc];
}

- (NSString*)getText {
    return [self.object objectForKey:@"text"] ;
}


- (NSData*)getVoiceData {
    return self.voice_data ;
}

@end
