//
//  TTProductsRequestManager.m
//  TimedTrainer
//
//  Created by Mohammed Islam on 8/13/15.
//  Copyright (c) 2015 Mohammed Islam. All rights reserved.
//

#import "TTProductsRequestManager.h"
#import <StoreKit/SKProductsRequest.h>
#import <StoreKit/SKProduct.h>
#import <StoreKit/SKPaymentQueue.h>
#import "TTProductObjectDecorator.h"

@interface TTProductsRequestManager () <SKProductsRequestDelegate>

@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, strong) NSArray *productIds;
@property (nonatomic, strong) NSMutableDictionary *productObjects;

// This serial queue will do lookup of productIds in batches
@property (nonatomic, strong) NSOperationQueue *lookupQueue;

@end

@implementation TTProductsRequestManager

+ (void)initSharedInstanceWithProductIds:(NSArray *)productIds
{
	TTProductsRequestManager *instance = [TTProductsRequestManager singletonInstance];

	NSAssert(instance.productIds.count == 0, @"This can't be called more than once");

	instance.productIds = productIds;
}

+ (TTProductsRequestManager *)sharedInstance
{
	TTProductsRequestManager *instance = [TTProductsRequestManager singletonInstance];

	NSAssert(instance.productIds.count > 0, @"Need to call -initSharedInstanceWithProductIds: first!");

	return instance;
}

+ (TTProductsRequestManager *)singletonInstance
{
	static TTProductsRequestManager *currentSessionManager;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		currentSessionManager = [[TTProductsRequestManager alloc] init];
	});

	return currentSessionManager;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.state = TTProductsRequestManagerStateNone;
		self.productObjects = [NSMutableDictionary dictionary];

		self.lookupQueue = [[NSOperationQueue alloc] init];
		self.lookupQueue.maxConcurrentOperationCount = 1; // Make it a serial queue
		self.lookupQueue.qualityOfService = NSQualityOfServiceBackground;
	}
	return self;
}

- (void)dealloc
{
	[self.productsRequest cancel];
}

+ (BOOL)canMakePayments
{
	return [SKPaymentQueue canMakePayments];
}

- (void)setProductIds:(NSArray *)productIds
{
	for (NSString *productId in productIds)
	{
		// If the product already exists, don't add it again
		if ([self productForId:productId])
		{
			NSAssert(false, @"The product shouldn't previously exist");
		}

		if (productId.length > 0)
		{
			TTProductObjectDecorator *product = [[TTProductObjectDecorator alloc] init];
			product.productId = productId;

			@synchronized(_productObjects)
			{
				[self.productObjects setObject:product forKey:productId];
			}
		}
	}

	[self lookupProducts];
}

- (TTProductObject *)productForId:(NSString *)productId
{
	if (productId.length > 0)
	{
		return nil;
	}

	TTProductObject *product;
	@synchronized(_productObjects)
	{
		product = [self.productObjects objectForKey:productId];
	}

	return product;
}

#pragma mark -
#pragma mark Product Lookup

- (void)lookupProducts
{
	NSMutableSet *productIds = [NSMutableSet set];

	@synchronized(_productObjects)
	{
		for (TTProductObjectDecorator *productObject in self.productObjects)
		{
			// If there is a productID
			// And if the state is either initial or error (for re-lookup)
			if (productObject.productId.length > 0 &&
				(productObject.state == TTProductObjectStateInitial ||
				productObject.state == TTProductObjectStateLookupError))
			{
				[productIds addObject:productObject.productId];
			}
		}
	}

	if (productIds.count > 0)
	{
		self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
		self.productsRequest.delegate = self;

		// Set all products as lookingUp
		@synchronized(_productObjects)
		{
			[self.productObjects enumerateKeysAndObjectsUsingBlock:^(NSString *productId, TTProductObjectDecorator *productObject, BOOL *stop) {
				productObject.state = TTProductObjectStateLookingUp;
			}];
		}

		[self.productsRequest start];
	}
}

#pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	NSArray *productsFromStore = response.products;

	if (productsFromStore.count == 0)
	{
		// Set error on all the products
		@synchronized(_productObjects)
		{
			[self.productObjects enumerateKeysAndObjectsUsingBlock:^(NSString *productId, TTProductObjectDecorator *productObject, BOOL *stop) {
				productObject.state = TTProductObjectStateLookupError;
			}];
		}

		return;
	}

	// Otherwise map the products from store to products objects
	NSMutableArray *loadedProductObjects = [NSMutableArray array];
	for (SKProduct *storeKitProduct in productsFromStore)
	{
		TTProductObjectDecorator *productObject = (TTProductObjectDecorator *)[self productForId:storeKitProduct.productIdentifier];

		if (productObject)
		{
			productObject.storeKitProduct = storeKitProduct;
			[loadedProductObjects addObject:productObject];
		}
	}

	// Mark any productObjects without storeKitProduct as errored
	@synchronized(_productObjects)
	{
		[self.productObjects enumerateKeysAndObjectsUsingBlock:^(NSString *productId, TTProductObjectDecorator *productObject, BOOL *stop) {
			if (productObject.storeKitProduct == nil)
			{
				productObject.state = TTProductObjectStateLookupError;
			}
		}];
	}

	if (self.delegate && [self.delegate respondsToSelector:@selector(productManager:didFinishLookupWithProductObjects:)])
	{
		[self.delegate productManager:self didFinishLookupWithProductObjects:loadedProductObjects.copy];
	}
}

@end
