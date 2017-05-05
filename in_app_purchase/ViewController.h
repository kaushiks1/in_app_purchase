//
//  ViewController.h
//  in_app_purchase
//
//  Created by jimit on 11/04/15.
//  Copyright (c) 2015 cg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "SVProgressHUD.h"


@interface ViewController : UIViewController<SKProductsRequestDelegate,SKRequestDelegate,SKPaymentTransactionObserver>
{
    NSMutableArray *arr1;
    BOOL flag;
    NSString *pid;
}

@end

