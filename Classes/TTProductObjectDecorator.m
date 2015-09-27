//
//  TTProductObjectDecorator.m
//  TimedTrainer
//
//  Created by Mohammed Islam on 9/22/15.
//  Copyright (c) 2015 Mohammed Islam. All rights reserved.
//

#import "TTProductObjectDecorator.h"
#import <StoreKit/StoreKit.h>

@interface TTProductObjectDecorator () <SKPaymentTransactionObserver>

@property (nonatomic, strong) SKPayment *storeKitPayment;

@end

@implementation TTProductObjectDecorator

@synthesize
state = _state;

- (void)setState:(TTProductObjectState)state
{
	@synchronized(self)
	{
		if (_state == state)
		{
			return;
		}

		_state = state;

		if (self.delegate && [self.delegate respondsToSelector:@selector(productObject:didChangeState:)])
		{
			[self.delegate productObject:self didChangeState:state];
		}
	}
}

- (void)dealloc
{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)setStoreKitProduct:(SKProduct *)storeKitProduct
{
	if (_storeKitProduct)
	{
		NSAssert(NO, @"We're not supposed to set this twice, what's going on?");

	}

	self.state = TTProductObjectStateLoaded;

	_storeKitProduct = storeKitProduct;

	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (SKPayment *)storeKitPayment
{
	if (!_storeKitPayment &&
		self.storeKitProduct)
	{
		_storeKitPayment = [SKPayment paymentWithProduct:self.storeKitProduct];
	}

	return _storeKitPayment;
}

- (BOOL)purchaseProduct
{
	if (self.state != TTProductObjectStateLoaded ||
		self.storeKitProduct == nil)
	{
		return NO;
	}

	self.state = TTProductObjectStatePurchasing;

	[[SKPaymentQueue defaultQueue] addPayment:self.storeKitPayment];

	return YES;
}

#pragma mark SKPaymentTransactionObserver

// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	[transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction *transaction, NSUInteger idx, BOOL *stop) {
		NSLog(@"updatedTransactions: %@", transactions);
	}];
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
	[transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction *transaction, NSUInteger idx, BOOL *stop) {
		NSLog(@"removedTransactions: %@", transactions);
	}];
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	NSLog(@"restoreCompletedTransactionsFailedWithError: %@", error);
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
}

@end
