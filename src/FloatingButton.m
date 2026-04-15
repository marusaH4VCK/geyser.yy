#import "FloatingButton.h"

@interface FloatingButton ()
@property (nonatomic, assign) CGPoint lastLocation;
@end

@implementation FloatingButton

static FloatingButton *sharedInstance = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWindow *window = [self getKeyWindow];
        if (window) {
            sharedInstance = [[FloatingButton alloc] initWithFrame:CGRectMake(window.bounds.size.width - 65, 120, 50, 50)];
            [window addSubview:sharedInstance];
        }
    });
    return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.9 green:0.3 blue:0.2 alpha:0.9];
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.4;
        self.layer.shadowRadius = 6;
        self.layer.shadowOffset = CGSizeMake(0, 3);
        [self setTitle:@"M" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:22];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        
        [self addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (UIWindow *)getKeyWindow {
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:[UIWindowScene class]]) {
            return [(UIWindowScene *)scene windows].firstObject;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}

- (void)onTap {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ToggleMenuNotification" object:nil];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.lastLocation = self.center;
    }
    self.center = CGPointMake(self.lastLocation.x + translation.x, self.lastLocation.y + translation.y);
}

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

@end
