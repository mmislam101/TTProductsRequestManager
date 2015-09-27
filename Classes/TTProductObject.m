//
//  TTProducts.m
//  TimedTrainer
//
//  Created by Mohammed Islam on 9/19/15.
//  Copyright (c) 2015 Mohammed Islam. All rights reserved.
//

#import "TTProductObject.h"

@implementation TTProductObject

- (instancetype)init
{
	self = [super init];
	if (self) {
		_state = TTProductObjectStateInitial;
	}
	return self;
}

- (BOOL)purchaseProduct
{
	// Let the decorator handle this
	return NO;
}

@end
