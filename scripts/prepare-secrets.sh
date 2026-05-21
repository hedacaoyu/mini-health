#!/bin/bash
# 运行此脚本，按提示操作，最后把输出内容添加到 GitHub Secrets

echo "================================================"
echo "  准备 GitHub Actions iOS 构建所需的 Secrets"
echo "================================================"
echo ""

# ── 1. 分发证书 (.p12) ───────────────────────────────────────────────
echo "【步骤 1】导出分发证书"
echo "  打开 macOS 钥匙串访问（Keychain Access）"
echo "  找到：Apple Distribution: <你的名字>"
echo "  右键 → 导出 → 保存为 /tmp/dist_cert.p12"
echo "  设置一个导出密码（记住它）"
echo ""
read -p "证书已导出到 /tmp/dist_cert.p12？按回车继续..."

if [ -f /tmp/dist_cert.p12 ]; then
  CERT_B64=$(base64 -i /tmp/dist_cert.p12)
  echo ""
  echo "✅ Secret 名称：IOS_CERT_BASE64"
  echo "   Secret 值（复制下面全部内容）："
  echo "---BEGIN---"
  echo "$CERT_B64"
  echo "---END---"
  echo ""
  read -p "请输入刚才设置的证书密码，用作 IOS_CERT_PASSWORD: " CERT_PASS
  echo "✅ Secret 名称：IOS_CERT_PASSWORD"
  echo "   Secret 值：$CERT_PASS"
else
  echo "❌ 未找到 /tmp/dist_cert.p12，请先导出证书"
fi

echo ""
echo "================================================"

# ── 2. 描述文件 (.mobileprovision) ──────────────────────────────────
echo "【步骤 2】下载 App Store 描述文件"
echo "  打开：https://developer.apple.com/account/resources/profiles/list"
echo "  找到 App Store Distribution 描述文件"
echo "  下载后保存到 /tmp/app.mobileprovision"
echo ""
read -p "描述文件已保存到 /tmp/app.mobileprovision？按回车继续..."

if [ -f /tmp/app.mobileprovision ]; then
  PROV_B64=$(base64 -i /tmp/app.mobileprovision)
  echo ""
  echo "✅ Secret 名称：IOS_PROVISION_BASE64"
  echo "   Secret 值（复制下面全部内容）："
  echo "---BEGIN---"
  echo "$PROV_B64"
  echo "---END---"
else
  echo "❌ 未找到 /tmp/app.mobileprovision"
fi

echo ""
echo "================================================"
echo "【步骤 3】Bundle ID"
echo "✅ Secret 名称：BUNDLE_ID"
echo "   Secret 值：com.joseph.healthapp（替换为你的实际 Bundle ID）"
echo ""
echo "================================================"
echo "【完成】在 GitHub 仓库 Settings → Secrets and variables → Actions"
echo "       点击 New repository secret，逐个添加上面 4 个 Secret"
echo "================================================"
