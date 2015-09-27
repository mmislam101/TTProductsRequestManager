//
//  TTProductObjectDecorator.h
//  TimedTrainer
//
//  Created by Mohammed Islam on 9/22/15.
//  Copyright (c) 2015 Mohammed Islam. All rights reserved.
//

#import "TTProductObject.h"

@class SKProduct;

@interface TTProductObjectDecorator : TTProductObject

@property (nonatomic, assign) TTProductObjectState state;
@property (nonatomic, strong) SKProduct *storeKitProduct;

@end
