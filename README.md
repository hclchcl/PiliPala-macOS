# PiliPala for macOS

基于 [guozhigq/pilipala](https://github.com/guozhigq/pilipala) 公开源码的 macOS 适配分支，保留原项目提交历史、作者信息和 GPL-3.0 许可。

当前适配预览版：**1.0.25-macos.1**。构建基线为上游提交 [`06f23f6`](https://github.com/guozhigq/pilipala/commit/06f23f67ca61f22db42ebabd9b979b2c2f4fa808)，源码版本号为 `1.0.25+1025`。这不是原项目未公开对应源码的 1.0.27 发布版。

## 下载与安装

从 [Releases](https://github.com/hclchcl/PiliPala-macOS/releases) 下载：

- `PiliPala-1.0.25-macos.1-arm64.dmg`：打开后将 PiliPala 拖入 Applications。
- `PiliPala-1.0.25-macos.1-arm64.zip`：解压后取得同一份 PiliPala.app。
- `SHA256SUMS.txt`：下载文件的 SHA-256 校验值。

适用 **Apple Silicon（M 系列芯片）Mac、macOS 12 及以上**。Intel Mac 不适用此安装包。

应用采用本地签名，未做 Apple Developer ID 签名或公证。下载后的首次启动可能需要在“系统设置 → 隐私与安全性”中允许打开。

## 适配内容

- 完成 Apple Silicon 正式构建，并统一 macOS 与插件的最低部署版本。
- 在首帧前完成全局设置与播放器服务初始化，避免初始化顺序导致启动失败。
- 注册 macOS WKWebView，实现内嵌网页与网页登录 Cookie 同步。
- 图片和评论截图使用 macOS 原生保存窗口。
- 设置独立应用标识、桌面窗口初始尺寸和最小尺寸。
- 绕开手机状态栏与外部链接监听接口；桌面全屏使用原生窗口切换。手机验证码插件在 macOS 上提示改用二维码或网页登录。
- 分类搜索补齐 WBI 请求签名，兼容服务端未返回分类数量的情况。
- 固定 Git 依赖提交，更新与 Dart 3.5 不兼容的少量间接依赖。

## 使用与验证边界

优先使用登录页右上角的二维码登录，也可选择网页登录。手机密码/短信验证所需的原生极验插件未移植。

未登录搜索目前可能触发哔哩哔哩验证，测试中出现了该限制；登录后搜索与登录持久化尚未验证。

原项目以手机交互为主，本分支保留其界面和业务实现。账号相关操作、直播、投屏、付费内容、部分手势及外部应用链接并未因此获得全面的桌面兼容保证。实际检查范围见 [运行验证记录](docs/VALIDATION.md)。

## 自行构建

使用 Flutter **3.24.5 arm64**、完整 Xcode 和 CocoaPods，在项目目录执行：

```sh
bash scripts/build-macos.sh
```

脚本生成应用 ZIP、DMG 与校验值。工具版本、原生快照编译器及依赖锁定说明见 [构建说明](docs/BUILD.md)。

## 来源与许可

- 源码与主要功能来自 [guozhigq/pilipala](https://github.com/guozhigq/pilipala) 及其贡献者；[原项目说明](docs/README-upstream.md) 予以保留。
- macOS 打包方向参考 [EvanWei-CAA/PilipalaX-for-macOS 1.0.1](https://github.com/EvanWei-CAA/PilipalaX-for-macOS/releases/tag/1.0.1)。该项目未提供适配源码，本分支的改动基于上述 PiliPala 公开源码完成。
- 继续采用 [GPL-3.0](LICENSE)。应用使用的 Flutter 与其他依赖分别遵循各自许可。
