//
//  RouteContent.h
//  karuta
//
//  Created by 荻原有二 on 2016/09/24.
//  Copyright © 2016年 Yuji Ogihara. All rights reserved.
//

#ifndef StationContent_h
#define StationContent_h

@interface StationContent : NSObject ;

@property (nonatomic,retain) PFObject *object ;
@property (nonatomic,retain) NSData  *voice_data ;

- (void)setObject:(PFObject*)data ;

- (NSString*)getText ;
- (NSData*)getVoiceData ;

@end

#endif /* QuestionListContent_h */
