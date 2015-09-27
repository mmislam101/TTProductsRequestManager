//
//  TTProducts.h
//  TimedTrainer
//
//  Created by Mohammed Islam on 9/19/15.
//  Copyright (c) 2015 Mohammed Islam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTProductObject;

typedef NS_ENUM(NSInteger, TTProductObjectState)
{
	TTProductObjectStateInitial,
	TTProductObjectStateLookingUp,
	TTProductObjectStateLookupError,
	TTProductObjectStateLoaded,
	TTProductObjectStatePurchasing,
	TTProductObjectStatePurchased,
};

@protocol TTProductObject <NSObject>

- (void)productObject:(TTProductObject *)product didChangeState:(TTProductObjectState)state;

@end

@interface TTProductObject : NSObject

@property (nonatomic, strong) NSString *productId;
@property (nonatomic, weak) id <TTProductObject> delegate;
@property (nonatomic, readonly) TTProductObjectState state;

- (BOOL)purchaseProduct;

@end
