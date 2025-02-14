//
//  BNRDrawView.m
//  TouchTracker
//
//  Created by Edwin Cardenas on 11/02/25.
//

#import "BNRDrawView.h"
#import "BNRLine.h"

@interface BNRDrawView ()

@property (nonatomic) NSMutableDictionary<NSValue *, BNRLine *> *linesInProgress;
@property (nonatomic) NSMutableArray<BNRLine *> *finishedLines;
@property (nonatomic, weak) BNRLine * _Nullable selectedLine;

@end

@implementation BNRDrawView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.linesInProgress = [NSMutableDictionary dictionary];
        self.finishedLines = [NSMutableArray array];
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                       initWithTarget:self action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.delaysTouchesBegan = YES;
        
        [self addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(tap:)];
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        
        [self addGestureRecognizer:tapRecognizer];
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
    
    [[UIColor redColor] set];
    
    for (NSValue *key in self.linesInProgress) {
        [self strokeLine:self.linesInProgress[key]];
    }
    
    if (self.selectedLine) {
        [[UIColor greenColor] set];
        [self strokeLine:self.selectedLine];
    }
}

- (BNRLine * _Nullable)lineAtPoint:(CGPoint)point
{
    for (BNRLine *line in self.finishedLines) {
        CGPoint start = line.begin;
        CGPoint end = line.end;
        
        for (float t = 0.0; t < 1.0; t += 0.05) {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);
            
            if (hypot(x - point.x, y - point.y) < 10.0) {
                return line;
            }
        }
    }
    
    return nil;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Message sent: %@", NSStringFromSelector(_cmd));
    
    for (UITouch *touch in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        CGPoint location = [touch locationInView:self];
        
        BNRLine *line = [[BNRLine alloc] init];
        line.begin = location;
        line.end = location;
        
        self.linesInProgress[key] = line;
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Message sent: %@", NSStringFromSelector(_cmd));
    
    for (UITouch *touch in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        CGPoint location = [touch locationInView:self];
        
        BNRLine *line = self.linesInProgress[key];
        
        line.end = location;
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Message sent: %@", NSStringFromSelector(_cmd));
    
    for (UITouch *touch in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        BNRLine *line = self.linesInProgress[key];
        
        [self.finishedLines addObject:line];
        [self.linesInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Message sent: %@", NSStringFromSelector(_cmd));
    
    for (UITouch *touch in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        [self.linesInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Actions

- (void)doubleTap:(UIGestureRecognizer *)gesture
{
    NSLog(@"Recognized double tap");
    
    [self.linesInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];
    [self setNeedsDisplay];
}

- (void)tap:(UIGestureRecognizer *)gesture
{
    NSLog(@"Recognized tap");
    
    CGPoint point = [gesture locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
    
    if (self.selectedLine) {
        [self becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                            action:@selector(deleteLine:)];
        menu.menuItems = @[deleteItem];
        
        [menu showMenuFromView:self rect:CGRectMake(point.x, point.y, 2, 2)];
    } else {
        [[UIMenuController sharedMenuController] hideMenuFromView:self];
    }
    
    [self setNeedsDisplay];
}

- (void)delete:(id)sender
{
    [self.finishedLines removeObject:self.selectedLine];
    
    [self setNeedsDisplay];
}


@end
