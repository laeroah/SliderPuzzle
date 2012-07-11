
#import "UIAlertViewHelper.h"
#import <objc/runtime.h>


@implementation UIAlertView (Context) 
static char ContextPrivateKey;
-(void)setUserInfo:(NSDictionary *)userInfo{
    objc_setAssociatedObject(self, &ContextPrivateKey, userInfo, 3);
}
-(NSDictionary *)userInfo{
    return objc_getAssociatedObject(self, &ContextPrivateKey);
}
@end
