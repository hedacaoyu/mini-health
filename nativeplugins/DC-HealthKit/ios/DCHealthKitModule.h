#import <Foundation/Foundation.h>
#import "DCUniModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCHealthKitModule : DCUniModule

/**
 * 请求 HealthKit 授权（仅步数读取权限）
 * callback: { success: bool, message: string }
 */
- (void)requestAuth:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback;

/**
 * 读取今日步数
 * callback: { success: bool, steps: number, message: string }
 */
- (void)getSteps:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback;

@end

NS_ASSUME_NONNULL_END
