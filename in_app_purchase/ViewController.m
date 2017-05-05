//
//  ViewController.m
//  in_app_purchase
//
//  Created by jimit on 11/04/15.
//  Copyright (c) 2015 cg. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    pid =@"com.preventheadche.unlock";////
    
    arr1=[[NSMutableArray alloc]initWithObjects:@"one",@"two",@"three",@"four",@"five",@"six",@"seven",@"eight",@"nine",@"ten", nil];
    
    
    CGRect frame=[UIScreen mainScreen].bounds;
    float wd,ht;
    wd=frame.size.width;
    ht=frame.size.height;
    
    
    UITableView *tableView;
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, wd, ht-100) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:tableView];
    
    UIButton *btn1;
    btn1=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn1.frame=CGRectMake(wd/2, ht-100, 100, 50);
    [btn1 setTitle:@"CLICK" forState:UIControlStateNormal];
    btn1.backgroundColor=[UIColor blueColor];
    [btn1 addTarget:self action:@selector(clickevent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    flag=YES;

    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"AppPurchased"])
    {
        return 5;
    }
    else{
        return 10;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    cell.textLabel.text = [arr1 objectAtIndex:indexPath.row];
    
    return cell;
    
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)clickevent
{
    
    NSLog(@"apple");
    [self unlockAllRecipes];
    
}



- (void)unlockAllRecipes
{
    SKProductsRequest *request= [[SKProductsRequest alloc]
                                 initWithProductIdentifiers: [NSSet setWithObject:pid]];////
    request.delegate = self;
    [request start];
    
    [self showProgress:YES];
}

- (void)showProgress:(BOOL)inBool
{
    if(inBool)
    {
        [SVProgressHUD showInfoWithStatus:@"wait"];
    }
    else
    {
        [SVProgressHUD dismiss];
    }
}

#pragma mark - payment methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSArray *myProduct = response.products;
    NSLog(@"%@",[[myProduct objectAtIndex:0] productIdentifier]);
    
    //Since only one product, we do not need to choose from the array. Proceed directly to payment.
    
    SKPayment *newPayment = [SKPayment paymentWithProduct:[myProduct objectAtIndex:0]];
    [[SKPaymentQueue defaultQueue] addPayment:newPayment];
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self showProgress:NO];
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self showProgress:NO];
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self showProgress:NO];
                [self failedTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"AppPurchased"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIAlertView *alert;
    alert = [[UIAlertView alloc]initWithTitle:@"You have purchased successfully, thank you!" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Restored");
    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    
    // You should make the update to your app based on what was purchased and inform user.
    // [self provideContent: transaction.payment.productIdentifier];
    
    // Finally, remove the transaction from the payment queue.
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"AppPurchased"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    UIAlertView *alert;
    alert = [[UIAlertView alloc]initWithTitle:@"You have resotred successfully, thank you!" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful"
                                                        message:@"Your purchase failed. Please try again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


@end
