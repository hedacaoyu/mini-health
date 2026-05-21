#!/bin/bash
# 编译 DC-HealthKit 插件 .a
# 用法：./build-plugin.sh [真实DCUniModule.h的路径]
# 示例：./build-plugin.sh /tmp/ios-sdk/SDK/Headers/DCUniModule.h

set -e

PLUGIN_DIR="$(cd "$(dirname "$0")/nativeplugins/DC-HealthKit/ios" && pwd)"
OUTPUT="$PLUGIN_DIR/libDC-HealthKit.a"
REAL_HEADER="$1"

# 如果传入了真实头文件路径，先替换
if [ -n "$REAL_HEADER" ] && [ -f "$REAL_HEADER" ]; then
  echo "▶ 使用真实 DCUniModule.h: $REAL_HEADER"
  cp "$REAL_HEADER" "$PLUGIN_DIR/DCUniModule.h"
else
  echo "⚠️  未传入真实头文件，使用现有 DCUniModule.h"
  echo "   建议: ./build-plugin.sh /path/to/real/DCUniModule.h"
fi

echo "▶ 编译 arm64..."
SDK=$(xcrun --sdk iphoneos --show-sdk-path)

xcrun clang \
  -target arm64-apple-ios13.0 \
  -isysroot "$SDK" \
  -fmodules \
  -fobjc-arc \
  -I "$PLUGIN_DIR" \
  -c "$PLUGIN_DIR/DCHealthKitModule.m" \
  -o "$PLUGIN_DIR/DCHealthKitModule.o"

xcrun libtool -static "$PLUGIN_DIR/DCHealthKitModule.o" -o "$OUTPUT"
rm "$PLUGIN_DIR/DCHealthKitModule.o"

echo "▶ 验证符号..."
xcrun nm -g "$OUTPUT" | grep -E "requestAuth|getSteps|HealthKit" | head -10
echo ""
echo "✅ 生成：$OUTPUT"
