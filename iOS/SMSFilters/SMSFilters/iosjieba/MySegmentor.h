//
//  MySegmentor.h
//  SMSFilters
//
//  Created by Qiwihui on 1/3/19.
//  Copyright © 2019 qiwihui. All rights reserved.
//

#import <Foundation/Foundation.h>

void ObjcJiebaInit(NSString * dictPath, NSString * hmmPath, NSString * userDictPath);

void ObjcJiebaCut(NSString * sentence, NSArray * words);
