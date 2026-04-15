#import <UIKit/UIKit.h>
#import "GameMenuUI.h"

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[GMMenuWindow sharedWindow] show];
    });
}
