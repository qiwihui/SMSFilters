//
//  iosjiebaWrappper.mm
//  iOSJiebaTest
//
//  Created by Qiwihui on 1/14/19.
//  Copyright © 2019 Qiwihui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iosjiebaWrapper.h"
#include "Segmentor.h"

@implementation JiebaWrapper

- (void) objcJiebaInit: (NSString *) dictPath forPath: (NSString *) hmmPath forDictPath: (NSString *) userDictPath {

    const char *cDictPath = [dictPath UTF8String];
    const char *cHmmPath = [hmmPath UTF8String];
    const char *cUserDictPath = [userDictPath UTF8String];
    
    JiebaInit(cDictPath, cHmmPath, cUserDictPath);
    
}

- (void) objcJiebaCut: (NSString *) sentence toWords: (NSMutableArray *) words {
    
    const char* cSentence = [sentence UTF8String];
    
    std::vector<std::string> wordsList;
    for (int i = 0; i < [words count];i++)
    {
        wordsList.push_back(wordsList[i]);
    }
    JiebaCut(cSentence, wordsList);
    
    [words removeAllObjects];
    std::for_each(wordsList.begin(), wordsList.end(), [&words](std::string str) {
        id nsstr = [NSString stringWithUTF8String:str.c_str()];
        [words addObject:nsstr];
    });
}

@end
