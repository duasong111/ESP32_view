# ESP32 控制应用

一个基于 Flutter 开发的 ESP32 设备控制应用，支持实时数据监控和多种智能设备控制功能。

## 功能特性

### 📱 核心功能
- **实时数据监控**：通过 WebSocket 接收 ESP32 发送的时间、温度、湿度数据
- **智能设备控制**：
  - **小灯控制**：支持开关、颜色选择（红、绿、蓝、黄、紫、白）、亮度调节（0-100%）
  - **风扇控制**：开关控制
  - **其他开关**：通用开关控制
  - **蜂鸣器控制**：开关控制
- **图片上传**：支持选择本地图片上传
- **用户认证**：登录和注册功能

### 🎨 UI 特性
- 简洁现代的卡片式布局
- 响应式设计，适配不同屏幕尺寸
- 实时状态反馈
- 直观的颜色选择器和亮度滑块
- 点击小灯卡片弹出详细控制对话框

### 🔧 技术特性
- **网络通信**：支持 HTTP 请求和 WebSocket 实时通信
- **环境配置**：支持多环境配置（开发、生产）
- **错误处理**：完善的错误处理和日志记录
- **模块化设计**：清晰的代码结构和模块化组织

## 技术栈

- **前端框架**：Flutter 3.5+
- **状态管理**：GetX
- **网络请求**：Dio
- **UI 组件库**：TDesign Flutter
- **实时通信**：WebSocket Channel
- **图片处理**：Image Picker
- **加密安全**：cryptography, ed25519_hd_key, pointycastle, encrypt
- **工具库**：intl (国际化), uuid

## 安装说明

### 前置条件
- **Flutter SDK**：3.5.0 或更高版本
- **Dart SDK**：3.5.0 或更高版本
- **开发环境**：
  - Android Studio (Android 开发)
  - Xcode (iOS 开发，仅 macOS)
- **设备要求**：
  - Android 5.0+ 或 iOS 11.0+

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/duasong111/ESP32_view.git
   cd Esp32_view
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **配置环境**
   - 打开 `lib/app/api/endpoints.dart` 文件
   - 修改 `_devRealDevice` 为你的 ESP32 设备局域网 IP
   ```dart
   static const String _devRealDevice = 'http://192.168.18.155:8000';  // 改成你局域网IP
   ```

4. **运行项目**
   - **Android**：
     ```bash
     flutter run --device-id <android-device-id>
     ```
   - **iOS**：
     ```bash
     flutter run --device-id <ios-device-id>
     ```
   - **模拟器**：
     ```bash
     flutter run
     ```

## 使用说明

### 1. 连接设备
- 确保手机和 ESP32 设备在同一局域网内
- 确保 ESP32 服务器正在运行并监听 8000 端口

### 2. 功能使用

#### 实时数据监控
- 应用启动后会自动通过 WebSocket 连接到 ESP32
- 时间卡片会实时显示 ESP32 发送的时间、温度和湿度数据

#### 小灯控制
- **开关控制**：点击小灯卡片上的开关按钮
- **详细控制**：点击小灯卡片弹出控制对话框
  - **颜色选择**：点击颜色圆形按钮选择颜色
  - **亮度调节**：拖动滑块调节亮度

#### 其他设备控制
- **风扇**：点击风扇卡片上的开关按钮
- **其他开关**：点击对应卡片上的开关按钮
- **蜂鸣器**：点击蜂鸣器卡片上的开关按钮

#### 图片上传
- 点击"上传图片"卡片
- 选择本地图片
- 图片路径会在控制台输出（可根据需要扩展上传逻辑）

### 3. API 接口

#### HTTP 接口
- **RGB 控制**：`POST /api/device/rgb`
  - 请求体：
    ```json
    {
      "state": "on", // 或 "off"
      "color": "blue", // 颜色：red, green, blue, yellow, purple, white
      "brightness": 30 // 亮度：0-100
    }
    ```

#### WebSocket 接口
- **数据推送**：`ws://<ip>:8000/esp32/data`
  - 接收数据格式：
    ```json
    {
      "payload": "{\"time\": \"2024-01-01T12:00:00\", \"temperature\": 25.5, \"humidity\": 60}"
    }
    ```

## 项目结构

```
lib/
├── app/
│   ├── api/              # API 相关
│   │   ├── client/       # 网络客户端
│   │   ├── services/     # 服务层
│   │   └── endpoints.dart # 接口端点定义
│   ├── main_view/        # 主界面
│   │   ├── home/         # 主页相关
│   │   ├── login/        # 登录相关
│   │   ├── home.dart     # 主页
│   │   └── login.dart    # 登录页
│   ├── models/           # 数据模型
│   └── utils/            # 工具类
├── routes/               # 路由
├── shared/               # 共享资源
│   ├── constants/        # 常量
│   └── widgets/          # 通用组件
└── main.dart             # 应用入口
```

## 注意事项

1. **网络连接**：确保手机和 ESP32 在同一局域网内
2. **IP 配置**：根据实际网络环境修改 `endpoints.dart` 中的 IP 地址
3. **服务器配置**：确保 ESP32 服务器正确配置并运行
4. **权限**：Android 设备需要授予网络和存储权限
5. **调试**：开发模式下可以查看控制台日志了解详细信息

## 故障排除

### 常见问题
1. **WebSocket 连接失败**
   - 检查 ESP32 IP 地址是否正确
   - 检查 ESP32 服务器是否正在运行
   - 检查网络连接是否正常

2. **控制命令不生效**
   - 检查 HTTP 请求是否成功
   - 检查 ESP32 是否正确处理控制命令
   - 查看控制台日志了解错误信息

3. **图片上传失败**
   - 检查存储权限是否授予
   - 检查图片路径是否正确

## 许可证

MIT License

## 更新日志

### v1.0.0
- 初始版本
- 实现基本的设备控制功能
- 添加实时数据监控
- 支持图片上传功能

---

**作者**：杜阿松
**联系方式**：2272168170@qq.com
**项目地址**：(https://github.com/duasong111/ESP32_view.git)

# ESP32_view
flutter做的ESP32的智能界面

