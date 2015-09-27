//
//  TTProductsRequestManager.h
//  TimedTrainer
//
//  Created by Mohammed Islam on 8/13/15.
//  Copyright (c) 2015 Mohammed Islam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTProductsRequestManager, TTProductObject;

typedef NS_ENUM(NSInteger, TTProductsRequestManagerResponse)
{
	TTProductsRequestManagerResponseFail,
	TTProductsRequestManagerResponseNotAvailable,
	TTProductsRequestManagerResponseSuccess
};

typedef NS_ENUM(NSInteger, TTProductsRequestManagerState)
{
	TTProductsRequestManagerStateNone,
	TTProductsRequestManagerStateLoadingProducts,
	TTProductsRequestManagerStateProductsLoaded,
	TTProductsRequestManagerStatePurchasing
};

@protocol TTProductsRequestManager <NSObject>

- (void)productManager:(TTProductsRequestManager *)manager didFinishLookupWithProductObjects:(NSArray *)productObjects;

@end

@interface TTProductsRequestManager : NSObject

// Must be called first before this singleton is used (so suggest placing in didLaunch
// The productIds will be cached as TTProductObjects.
// Suggest managing these productObjects yourself. You can become their delegate and update your
// views to handle them.
+ (void)initSharedInstanceWithProductIds:(NSArray *)productIds;
+ (TTProductsRequestManager *)sharedInstance;

+ (BOOL)canMakePayments;

@property (nonatomic, weak) id <TTProductsRequestManager> delegate;

// TTProductObject will have all the necessary status information that you need
// TTProductObject will also be what you need to use for purchasing
- (TTProductObject *)productForId:(NSString *)productId;

#warning need to figure out how to re-lookup in case of failures

@property (nonatomic, assign) TTProductsRequestManagerState state;

@end
