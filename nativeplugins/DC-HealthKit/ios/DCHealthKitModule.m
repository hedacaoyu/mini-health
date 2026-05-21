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

    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:
                                HKQuantityTypeIdentifierStepCount];
    NSSet *readTypes = [NSSet setWithObject:stepType];

    [self.healthStore requestAuthorizationToShareTypes:nil
                                             readTypes:readTypes
                                           completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                callback(@{ @"success": @NO,
                            @"message": error.localizedDescription ?: @"授权失败" }, NO);
            } else {
                // HealthKit 的 success 只代表弹窗完成，不代表用户同意
                // 授权结果由后续 query 反映，这里统一返回 YES
                callback(@{ @"success": @YES, @"message": @"" }, NO);
            }
        });
    }];
}

- (void)getSteps:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if (![HKHealthStore isHealthDataAvailable]) {
        callback(@{ @"success": @NO, @"steps": @0,
                    @"message": @"该设备不支持 HealthKit" }, NO);
        return;
    }

    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:
                                HKQuantityTypeIdentifierStepCount];

    NSCalendar *cal   = [NSCalendar currentCalendar];
    NSDate *startDay  = [cal startOfDayForDate:[NSDate date]];
    NSDate *now       = [NSDate date];

    NSPredicate *pred = [HKQuery predicateForSamplesWithStartDate:startDay
                                                          endDate:now
                                                          options:HKQueryOptionStrictStartDate];

    HKStatisticsQuery *query =
        [[HKStatisticsQuery alloc] initWithQuantityType:stepType
                                quantitySamplePredicate:pred
                                               options:HKStatisticsOptionCumulativeSum
                                     completionHandler:^(HKStatisticsQuery *q,
                                                         HKStatistics *result,
                                                         NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                callback(@{ @"success": @NO, @"steps": @0,
                            @"message": error.localizedDescription ?: @"查询失败" }, NO);
                return;
            }
            NSInteger steps = 0;
            if (result.sumQuantity) {
                steps = (NSInteger)[result.sumQuantity doubleValueForUnit:[HKUnit countUnit]];
            }
            callback(@{ @"success": @YES, @"steps": @(steps), @"message": @"ok" }, NO);
        });
    }];

    [self.healthStore executeQuery:query];
}

@end
