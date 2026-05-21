# mini-health

从 Apple Watch / iPhone 读取今日步数的最小 uni-app 项目。

## 项目结构

```
mini-health/
├── pages/index/index.vue          # 首页 UI（今日步数 + 读取按钮）
├── nativeplugins/DC-HealthKit/
│   ├── ios/
│   │   ├── DCHealthKitModule.h    # 原生模块头文件
│   │   └── DCHealthKitModule.m    # HealthKit 查询实现
│   └── package.json               # 插件声明
├── ios-profile/mini-health.entitlements  # HealthKit 权限
└── manifest.json                  # App 配置（含 HealthKit 权限声明）
```

## 接入步骤

### 1. 编译原生插件

在 HBuilderX 中使用「云打包」或「自定义基座」，框架会自动处理 `.m` 源文件编译。  
也可手动将 `DCHealthKitModule.h/.m` 加入 Xcode 工程（离线打包时使用）。

### 2. HBuilderX 云打包配置

`manifest.json → App 常用其他设置 → iOS 隐私信息访问的许可描述` 已包含：
- `NSHealthShareUsageDescription`
- `NSHealthUpdateUsageDescription`

### 3. Xcode 离线打包（可选）

1. 打开生成的 Xcode 工程
2. `Signing & Capabilities → + Capability → HealthKit`
3. 将 `ios-profile/mini-health.entitlements` 内容合并到工程 entitlements
4. `Build Phases → Link Binary → +` 添加 `HealthKit.framework`

### 4. Apple Developer 配置

App ID 需开启 **HealthKit** capability（App Identifiers → Edit → HealthKit ✓）。

## 运行

```bash
# HBuilderX：运行 → 运行到手机或模拟器 → iOS（需真机，模拟器无 HealthKit 数据）
```

## 数据来源

步数来自 iPhone + Apple Watch 的合并数据，统计范围为**当天 00:00 至当前时刻**。
