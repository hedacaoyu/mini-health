/**
 * DCUniModule 编译占位 stub
 * 优先从 HBuilderX.app 提取真实文件替换此文件：
 *   find ~/HBuilderX -name "DCUniModule.h"
 *
 * 真实 SDK 运行时由 HBuilderX 基座提供，此文件仅用于 .a 编译通过。
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// JS 调用原生后的回调块
/// @param result  返回给 JS 的数据（NSDictionary / NSString 等）
/// @param keepAlive YES 表示回调可多次触发（长连接），NO 表示单次
typedef void (^UniModuleKeepAliveCallback)(id _Nullable result, BOOL keepAlive);

/// 所有原生模块的基类
@interface DCUniModule : NSObject
@end

/**
 * 导出方法宏 —— 在每个方法前声明，让 HBuilderX JS 引擎可以调用它
 * 此 stub 使用 __LINE__ 生成唯一符号以允许多次调用
 */
#define _UNI_CONCAT(a, b) a##b
#define _UNI_EXPORT(line) \
    + (void)_UNI_CONCAT(_uni_export_method_, line) {}
#define UNI_EXPORT_METHOD(sel) _UNI_EXPORT(__LINE__)

NS_ASSUME_NONNULL_END
