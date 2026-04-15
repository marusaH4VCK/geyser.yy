#import <UIKit/UIKit.h>
#import "GameMenuUI.h"

static UIWindow *menuWindow = nil;
static GMMenuViewController *menuVC = nil;

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!menuWindow) {
            menuVC = [GMMenuViewController sharedController];
            menuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            menuWindow.windowLevel = UIWindowLevelAlert + 100;
            menuWindow.rootViewController = menuVC;
            menuWindow.backgroundColor = [UIColor clearColor];
            menuWindow.hidden = NO;
            [menuVC show];
        }
    });
}
