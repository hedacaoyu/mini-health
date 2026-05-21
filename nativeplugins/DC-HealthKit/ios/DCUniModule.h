/**
 * DCUniModule 编译占位 stub
 * GitHub Actions 会尝试从 DCloud CDN 下载真实版本替换此文件
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^UniModuleKeepAliveCallback)(id _Nullable result, BOOL keepAlive);

@interface DCUniModule : NSObject
@end

#define _UNI_CONCAT(a, b) a##b
#define _UNI_EXPORT(line) \
    + (void)_UNI_CONCAT(_uni_export_method_, line) {}
#define UNI_EXPORT_METHOD(sel) _UNI_EXPORT(__LINE__)

NS_ASSUME_NONNULL_END
