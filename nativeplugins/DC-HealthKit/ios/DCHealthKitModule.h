#import <Foundation/Foundation.h>
#import "DCUniModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCHealthKitModule : DCUniModule

- (void)requestAuth:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback;
- (void)getSteps:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback;

@end

NS_ASSUME_NONNULL_END
