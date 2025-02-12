//
//  BNRDrawViewController.m
//  TouchTracker
//
//  Created by Edwin Cardenas on 11/02/25.
//

#import "BNRDrawViewController.h"
#import "BNRDrawView.h"

@implementation BNRDrawViewController


#pragma mark - Lifecycle

- (void)loadView
{
    self.view = [[BNRDrawView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor yellowColor];
}


@end
