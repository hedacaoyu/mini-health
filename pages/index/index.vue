<template>
  <view class="container">
    <view class="card">
      <view class="icon-wrap">
        <text class="icon">♥</text>
      </view>
      <text class="label">今日步数</text>
      <text class="steps">{{ stepsDisplay }}</text>
      <text v-if="lastUpdated" class="updated">更新于 {{ lastUpdated }}</text>
    </view>

    <button
      class="btn"
      :loading="loading"
      :disabled="loading"
      @tap="readHealth"
    >
      {{ loading ? '读取中...' : '读取 Apple Health' }}
    </button>

    <text v-if="errorMsg" class="error">{{ errorMsg }}</text>
  </view>
</template>

<script>
// #ifdef APP-PLUS
let healthKit = null
try {
  healthKit = uni.requireNativePlugin('DC-HealthKit')
} catch (e) {}
// #endif

const TIMEOUT_MS = 10000 // 10 秒超时保护

export default {
  data() {
    return {
      steps: null,
      loading: false,
      errorMsg: '',
      lastUpdated: '',
      _timer: null
    }
  },
  computed: {
    stepsDisplay() {
      if (this.steps === null) return '---'
      return Number(this.steps).toLocaleString()
    }
  },
  beforeDestroy() {
    this._clearTimer()
  },
  methods: {
    _clearTimer() {
      if (this._timer) {
        clearTimeout(this._timer)
        this._timer = null
      }
    },
    _startTimeout(msg) {
      this._clearTimer()
      this._timer = setTimeout(() => {
        this.loading = false
        this.errorMsg = msg || '操作超时，请重试'
      }, TIMEOUT_MS)
    },

    readHealth() {
      // #ifdef APP-PLUS
      this.errorMsg = ''

      // ① 插件未加载检测
      if (!healthKit || typeof healthKit.requestAuth !== 'function') {
        this.errorMsg = '原生插件未加载，请使用离线打包（见控制台说明）'
        console.error(
          '[DC-HealthKit] requireNativePlugin 返回空或方法缺失。\n' +
          '云打包不编译 .m 源文件，请改用 HBuilderX 离线打包并将\n' +
          'DCHealthKitModule.h/.m 加入 Xcode 工程，链接 HealthKit.framework。'
        )
        return
      }

      this.loading = true
      this._startTimeout('授权请求超时')

      // ② requestAuth —— 仅弹出系统授权弹窗，callback 无论用户选择什么都会触发
      healthKit.requestAuth({}, () => {
        // HealthKit 规定：无论用户授权/拒绝，这里都继续查询
        // 拒绝时 query 会返回 0 步，不会报错
        this._clearTimer()
        this._startTimeout('读取步数超时')

        healthKit.getSteps({}, (result) => {
          this._clearTimer()
          this.loading = false
          if (result && result.success) {
            this.steps = result.steps
            this.lastUpdated = new Date().toLocaleTimeString('zh-CN', {
              hour: '2-digit',
              minute: '2-digit'
            })
          } else {
            this.errorMsg = (result && result.message) || '读取失败'
          }
        })
      })
      // #endif

      // #ifndef APP-PLUS
      uni.showToast({ title: '仅支持 iOS App', icon: 'none' })
      // #endif
    }
  }
}
</script>

<style scoped>
.container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40rpx;
  background-color: #f5f5f5;
}

.card {
  width: 100%;
  background: #ffffff;
  border-radius: 24rpx;
  padding: 60rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.06);
  margin-bottom: 48rpx;
}

.icon-wrap {
  width: 100rpx;
  height: 100rpx;
  background: #fff0f0;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32rpx;
}

.icon {
  font-size: 48rpx;
  color: #ff3b30;
}

.label {
  font-size: 28rpx;
  color: #8e8e93;
  margin-bottom: 16rpx;
  letter-spacing: 2rpx;
}

.steps {
  font-size: 96rpx;
  font-weight: 700;
  color: #1c1c1e;
  line-height: 1.1;
  letter-spacing: -2rpx;
}

.updated {
  font-size: 24rpx;
  color: #aeaeb2;
  margin-top: 16rpx;
}

.btn {
  width: 100%;
  height: 96rpx;
  line-height: 96rpx;
  background: #ff3b30;
  color: #ffffff;
  font-size: 32rpx;
  font-weight: 600;
  border-radius: 16rpx;
  border: none;
  letter-spacing: 2rpx;
}

.btn[disabled] {
  opacity: 0.6;
}

.error {
  margin-top: 24rpx;
  font-size: 26rpx;
  color: #ff3b30;
  text-align: center;
}
</style>
