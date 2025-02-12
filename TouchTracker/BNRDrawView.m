//
//  BNRDrawView.m
//  TouchTracker
//
//  Created by Edwin Cardenas on 11/02/25.
//

#import "BNRDrawView.h"
#import "BNRLine.h"

@interface BNRDrawView ()

@property (nonatomic) BNRLine *currentLine;
@property (nonatomic, copy) NSMutableArray<BNRLine *> *finishedLines;

@end

@implementation BNRDrawView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.finishedLines = [NSMutableArray array];
        self.backgroundColor = [UIColor grayColor];
    }
    
    return self;
}

- (void)strokeLine:(BNRLine *)line
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 10;
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    [bezierPath moveToPoint:line.begin];
    [bezierPath addLineToPoint:line.end];
    [bezierPath stroke];
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor blackColor] set];
    
    for (BNRLine *line in self.finishedLines) {
        [self strokeLine:line];
    }
    
    if (self.currentLine) {
        [[UIColor redColor] set];
        [self strokeLine:self.currentLine];
    }
}


@end
