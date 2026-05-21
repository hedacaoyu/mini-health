#import "DCHealthKitModule.h"
#import <HealthKit/HealthKit.h>

@interface DCHealthKitModule ()
@property (nonatomic, strong) HKHealthStore *healthStore;
@end

@implementation DCHealthKitModule

UNI_EXPORT_METHOD(@selector(requestAuth:callback:))
UNI_EXPORT_METHOD(@selector(getSteps:callback:))

- (HKHealthStore *)healthStore {
    if (!_healthStore) {
        _healthStore = [[HKHealthStore alloc] init];
    }
    return _healthStore;
}

- (void)requestAuth:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if (![HKHealthStore isHealthDataAvailable]) {
        callback(@{ @"success": @NO, @"message": @"该设备不支持 HealthKit" }, NO);
        return;
    }

    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSet *readTypes = [NSSet setWithObject:stepType];

    // 注意：HealthKit 的 success 只表示「弹窗成功显示」，不表示「用户已授权」
    // 用户点拒绝时 success 同样为 YES，无法在此区分授权结果
    // 正确做法：弹窗后统一回调 success=YES，让后续 query 自行处理权限状态
    [self.healthStore requestAuthorizationToShareTypes:nil
                                             readTypes:readTypes
                                           completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                // 系统级错误（极少见，如设备不支持）
                NSString *msg = error.localizedDescription ?: @"授权请求失败";
                callback(@{ @"success": @NO, @"message": msg }, NO);
            } else {
                // 无论用户授权/拒绝，均回调 YES，由 getSteps 的查询结果反映实际状态
                callback(@{ @"success": @YES, @"message": @"授权弹窗已处理" }, NO);
            }
        });
    }];
}

- (void)getSteps:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if (![HKHealthStore isHealthDataAvailable]) {
        callback(@{ @"success": @NO, @"steps": @0, @"message": @"该设备不支持 HealthKit" }, NO);
        return;
    }

    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    // 今日 00:00 ~ 现在
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startOfDay = [calendar startOfDayForDate:[NSDate date]];
    NSDate *now = [NSDate date];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startOfDay
                                                               endDate:now
                                                               options:HKQueryOptionStrictStartDate];

    HKStatisticsQuery *query =
        [[HKStatisticsQuery alloc] initWithQuantityType:stepType
                                quantitySamplePredicate:predicate
                                               options:HKStatisticsOptionCumulativeSum
                                     completionHandler:^(HKStatisticsQuery *q,
                                                         HKStatistics *result,
                                                         NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                callback(@{
                    @"success": @NO,
                    @"steps": @0,
                    @"message": error.localizedDescription ?: @"查询失败"
                }, NO);
                return;
            }

            double steps = 0;
            if (result.sumQuantity) {
                steps = [result.sumQuantity doubleValueForUnit:[HKUnit countUnit]];
            }
            callback(@{
                @"success": @YES,
                @"steps": @((NSInteger)steps),
                @"message": @"ok"
            }, NO);
        });
    }];

    [self.healthStore executeQuery:query];
}

@end
