# ✅ 演示程序正在运行！

## 当前状态

✅ **Material3Demo.exe 正在运行**
- 进程 ID: 4784
- 位置: `demos\Material3Demo\build\Material3Demo.exe`

---

## 如果你没看到窗口

### 检查 1：任务栏

窗口可能在后台，检查任务栏是否有 **Material3Demo** 图标

### 检查 2：最小化

窗口可能被最小化了，点击任务栏图标恢复

### 检查 3：多显示器

如果你有多个显示器，窗口可能在另一个屏幕上

### 检查 4：重新运行

```powershell
# 停止当前进程
Stop-Process -Name Material3Demo -Force

# 重新运行
.\scripts\run-demo.ps1
```

---

## 手动运行

### 方法 1：双击运行

1. 打开文件管理器
2. 导航到：`D:\编程项目\freeWindows\demos\Material3Demo\build`
3. 双击 `Material3Demo.exe`

### 方法 2：命令行运行

```powershell
# 设置 Qt 路径
$env:PATH = "D:\QT\6.9.3\mingw_64\bin;$env:PATH"

# 运行
.\demos\Material3Demo\build\Material3Demo.exe
```

### 方法 3：使用脚本

```powershell
.\scripts\run-demo.ps1
```

---

## 你应该看到

一个漂亮的窗口：

```
╭─────────────────────────────────╮
│ Material 3 Demo            × │  ← 标题栏
├─────────────────────────────────┤
│                                 │
│  Material 3 演示                │  ← 白色大标题
│  使用 Qt 实现的现代化界面       │  ← 副标题
│                                 │
│  ╭─────────────────────╮       │
│  │   主要按钮          │       │  ← 紫色按钮
│  ╰─────────────────────╯       │
│                                 │
│  ╭─────────────────────╮       │
│  │   次要按钮          │       │  ← 灰色按钮
│  ╰─────────────────────╯       │
│                                 │
│  ╭─────────────────────╮       │
│  │   第三按钮          │       │  ← 粉色按钮
│  ╰─────────────────────╯       │
│                                 │
╰─────────────────────────────────╯
```

**特性**：
- ✅ 圆角窗口
- ✅ 紫色渐变背景
- ✅ 带阴影的按钮
- ✅ 点击按钮有动画
- ✅ 可以拖动窗口（拖动标题栏）
- ✅ 点击 × 关闭窗口

---

## 测试功能

### 1. 拖动窗口
- 点击标题栏并拖动

### 2. 点击按钮
- 点击任意按钮，看动画效果

### 3. 关闭窗口
- 点击右上角的 × 按钮

---

## 如果还是看不到

### 检查进程

```powershell
# 查看进程是否运行
Get-Process Material3Demo -ErrorAction SilentlyContinue
```

### 查看错误

```powershell
# 在命令行运行，查看错误信息
$env:PATH = "D:\QT\6.9.3\mingw_64\bin;$env:PATH"
.\demos\Material3Demo\build\Material3Demo.exe
```

### 检查 Qt DLL

```powershell
# 确保 Qt DLL 可访问
Test-Path "D:\QT\6.9.3\mingw_64\bin\Qt6Core.dll"
Test-Path "D:\QT\6.9.3\mingw_64\bin\Qt6Gui.dll"
Test-Path "D:\QT\6.9.3\mingw_64\bin\Qt6Widgets.dll"
```

---

## 重新构建

如果需要重新构建：

```powershell
# 清理
Remove-Item demos\Material3Demo\build -Recurse -Force

# 重新配置
$env:PATH = "D:\QT\6.9.3\mingw_64\bin;D:\QT\Tools\mingw1310_64\bin;$env:PATH"
cmake -S demos\Material3Demo -B demos\Material3Demo\build -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=D:\QT\6.9.3\mingw_64

# 重新构建
cmake --build demos\Material3Demo\build

# 运行
.\demos\Material3Demo\build\Material3Demo.exe
```

---

## 下一步

### 修改代码

编辑 `demos\Material3Demo\modernwindow.cpp`：

```cpp
// 修改标题（第 52 行）
QLabel* title = new QLabel("我的第一个 Qt 应用");

// 修改颜色（第 180 行）
gradient.setColorAt(0, QColor("#FF0000"));  // 改成红色
gradient.setColorAt(1, QColor("#CC0000"));

// 添加更多按钮（第 70 行后）
contentLayout->addWidget(createMaterial3Button("新按钮", "#00FF00"));
```

然后重新构建并运行！

---

**创建时间**：2025-10-30  
**状态**：✅ 程序正在运行

