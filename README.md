# 试衣间 App

AI智能试衣间，拍照添加衣服自动抠图，虚拟试穿搭配。

## 功能

- 📸 衣柜管理：拍照/相册添加衣服，AI自动抠图
- 👔 虚拟试衣：上衣/下装/鞋子/配饰叠加预览
- 💾 搭配保存：保存喜欢的搭配方案
- 📊 衣柜统计：最常穿、闲置提醒
- 📤 分享功能：一键分享穿搭图片

## 构建 APK

### 方法1：GitHub Actions（推荐）

1. 创建 GitHub 仓库
2. 推送代码
3. 进入 Actions 页面，运行 "Build APK"
4. 下载 artifact 中的 APK

### 方法2：本地构建

```bash
flutter pub get
flutter build apk --release
```

APK 位置：`build/app/outputs/flutter-apk/app-release.apk`

## 配置

编辑 `lib/services/remove_bg_service.dart`，替换 API Key：
```dart
static const _apiKey = 'YOUR_REMOVE_BG_API_KEY';
```

获取 Key：https://www.remove.bg/api
