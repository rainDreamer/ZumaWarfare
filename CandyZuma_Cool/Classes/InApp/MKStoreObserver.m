//
//  MKStoreObserver.m
//  MKStoreKit (Version 4.2)
//
//  Created by Mugunth Kumar on 17-Nov-2010.
//  Copyright 2010 Steinlogic. All rights reserved.
//
//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices

#import "MKStoreObserver.h"
#import "MKStoreManager.h"

@interface MKStoreManager (InternalMethods)

// these three functions are called from MKStoreObserver
- (void) transactionCanceled: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

-(void) provideContent: (NSString*) productIdentifier
            forReceipt:(NSData*) receiptData withTransaction:(SKPaymentTransaction*)transaction;
@end

@implementation MKStoreObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    int countEventsTracked = 0;
    
	for (SKPaymentTransaction *transaction in transactions)
	{
        // default tracking event name
        NSString *eventName = @"purchase";
        // self.products is the dictionary (NString, SKProduct) to be created by the user
        
        // get the product associated with this transaction
        SKProduct *product = (SKProduct *)([[MKStoreManager sharedManager] getProductById:transaction.payment.productIdentifier]);
        
        // assign the currency code extracted from the transaction
        NSString *currencyCode = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
        if(nil != product) {
            // extract transaction product quantity
            int quantity = transaction.payment.quantity; // extract unit price of the product
            float unitPrice = [product.price floatValue];
            // assign revenue generated from the current product
            float revenue = unitPrice * quantity; // create MAT tracking event item
            
            // Note: Only the following keys are recognized: item, unit_price, quantity, revenue
            NSDictionary *dictItem = @{ @"item" : product.localizedTitle,
                                        @"unit_price" : [NSString stringWithFormat:@"%f", unitPrice],
                                        @"quantity" : [NSString stringWithFormat:@"%d", quantity],
                                        @"revenue" : [NSString stringWithFormat:@"%f", revenue]
                                        };
            NSArray *arrEventItems = @[ dictItem ];
            BOOL shouldTrackEvent = false;
            
            switch (transaction.transactionState) {
                case SKPaymentTransactionStatePurchased: {
                    // purchase successful
                    NSLog(@"Purchase Transaction Successful");
                    shouldTrackEvent = true;
                    // mark the transaction as completed
                    [self completeTransaction:transaction];
                    break;
                }
                case SKPaymentTransactionStateFailed: {
                    // purchase failed
                    NSLog(@"Purchase Transaction Failed: error = %@", transaction.error);
                    shouldTrackEvent = false;
                    // mark the transaction as completed
                    [self failedTransaction:transaction];
                    break;
                }
                case SKPaymentTransactionStateRestored: {
                    // purchase restored
                    NSLog(@"Purchase Transaction Restored"); // mark the transaction as completed
                    [self restoreTransaction:transaction];
                    break;
                }
                case SKPaymentTransactionStatePurchasing: default:
                    break;
            }
            NSLog(@"Event Item = %@", arrEventItems);
            if(shouldTrackEvent) {
                // track the purchase transaction event
                // Any extra revenue that might be generated over and above the revenues generated from event items.
                // Total event revenue = sum of even item revenues in arrEventItems + extraRevenue
                float extraRevenue = 0; // default to zero
                NSLog(@"Transaction event tracked: %@", eventName);
                // increment the tracked events count
                ++countEventsTracked;
            }
        }
    }
//    if(0 < countEventsTracked) {
//        NSString *alertMessage = [NSString stringWithFormat:@"%d in-app purchase transaction events tracked.", countEventsTracked];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MobileAppTracker" message:alertMessage
//                                                       delegate:nil cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//                              [alert show];
//    }
}
                    
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
  [[MKStoreManager sharedManager] restoreFailedWithError:error];    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue 
{
  [[MKStoreManager sharedManager] restoreCompleted];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{	
	[[MKStoreManager sharedManager] transactionCanceled:transaction];
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{			
#if TARGET_OS_IPHONE
  [[MKStoreManager sharedManager] provideContent:transaction.payment.productIdentifier 
                                      forReceipt:transaction.transactionReceipt withTransaction:transaction];
#elif TARGET_OS_MAC
  [[MKStoreManager sharedManager] provideContent:transaction.payment.productIdentifier 
                                      forReceipt:nil];
#endif
  
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{	
#if TARGET_OS_IPHONE
  [[MKStoreManager sharedManager] provideContent: transaction.originalTransaction.payment.productIdentifier
                                      forReceipt:transaction.transactionReceipt withTransaction:transaction];
#elif TARGET_OS_MAC
  [[MKStoreManager sharedManager] provideContent: transaction.originalTransaction.payment.productIdentifier
                                      forReceipt:nil];
#endif
	
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

@end
