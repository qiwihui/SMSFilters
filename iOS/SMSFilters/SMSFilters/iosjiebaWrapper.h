//
//  iosjiebaWrapper.h
//  SMSFilters
//
//  Created by Qiwihui on 1/14/19.
//  Copyright © 2019 qiwihui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JiebaWrapper : NSObject

- (void) objcJiebaInit: (NSString *) dictPath forPath: (NSString *) hmmPath forDictPath: (NSString *) userDictPath;
- (void) objcJiebaCut: (NSString *) sentence toWords: (NSMutableArray *) words;

@end
