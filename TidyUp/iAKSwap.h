//
//  iAKSwap.h
//  tidyUp
//
//  Created by Xiaonan Wang on 7/30/14.
//  Copyright (c) 2014 iAK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iAKObject.h"

@class iAKObject;

@interface iAKSwap : NSObject

@property (strong, nonatomic) iAKObject *objectA;
@property (strong, nonatomic) iAKObject *objectB;

@end
