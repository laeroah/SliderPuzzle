
#import "UIAlertViewHelper.h"

enum {
    OBJC_ASSOCIATION_ASSIGN = 0,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,
    OBJC_ASSOCIATION_RETAIN = 01401,
    OBJC_ASSOCIATION_COPY = 01403
};
@implementation UIAlertView (Context) 
static char ContextPrivateKey;
-(void)setUserInfo:(NSDictionary *)userInfo{
    objc_setAssociatedObject(self, &ContextPrivateKey, userInfo, 3);
}
-(NSDictionary *)userInfo{
    return objc_getAssociatedObject(self, &ContextPrivateKey);
}
@end
