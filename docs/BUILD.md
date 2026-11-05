# macOS 构建说明

此分支当前以 Apple Silicon（arm64）、macOS 12 及以上为构建目标。

## 工具

- Flutter **3.24.5 arm64**，Dart 3.5.4；不要直接换用最新 Flutter。
- 完整 Xcode 及其 macOS SDK。
- CocoaPods 1.15.2 或兼容版本。
- Python 3，用于读取 Flutter 版本与安装路径。

在 Apple Silicon Mac 上执行：

```sh
git clone https://github.com/hclchcl/PiliPala-macOS.git
cd PiliPala-macOS
bash scripts/build-macos.sh
```

产物位于 `dist/`，也可把目标文件夹作为脚本第一个参数传入。

依赖版本记录在 `pubspec.lock`、`macos/Podfile.lock`；Git 依赖固定到提交。
脚本使用 `--enforce-lockfile` 核验依赖锁定文件。

## Flutter 原生快照编译器

Flutter 3.24.5 的 macOS 构建流程默认选用 Intel 版 `gen_snapshot_arm64`。
脚本会检查该文件的运行架构；必要时从 Flutter 官方存储下载同一 engine
提交 `a18df97ca57a249df5d8d68cd0820600223ce262` 的 `darwin-arm64-release/artifacts.zip`，
核对固定 SHA-256 后更新此 Flutter SDK 缓存中的快照编译器。
下载内容来自官方 Flutter 发布服务，应用运行时不依赖该编译工具。

## 当前 Xcode 适配

- 最低部署版本统一为 macOS 12，包括 CocoaPods 依赖目标。
- 主工程与插件构建架构固定为 arm64。
- 更新了 Xcode 工程元数据及 `@main` 入口。
- `win32`、`ffi`、`archive` 的锁定版本已更新，以兼容 Dart 3.5。

当前构建与运行验证环境见 [VALIDATION.md](VALIDATION.md)。
此仓库不包含 Developer ID 证书或 Apple 公证凭据；构建结果采用本地签名。
