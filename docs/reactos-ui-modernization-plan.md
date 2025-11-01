# ReactOS UI 现代化迁移计划

## 配色方案

**主题**：天蓝色 + 草绿色 + 粉红色

```
颜色定义：
- 天蓝色 (Sky Blue): #87CEEB
- 草绿色 (Lawn Green): #7CFC00
- 粉红色 (Hot Pink): #FF69B4

渐变背景：
天蓝色 → 草绿色 → 粉红色
```

---

## 迁移策略

### 阶段 1：创建 Qt 组件库（1 个月）

#### 1.1 基础组件

**位置**：`src/qt-ui/components/`

##### ModernWindow（现代化窗口基类）
```cpp
// 文件：src/qt-ui/components/ModernWindow.h
class ModernWindow : public QMainWindow {
    Q_OBJECT
public:
    ModernWindow(QWidget *parent = nullptr);
    
protected:
    void paintEvent(QPaintEvent *event) override;
    void setupModernUI();
    
private:
    QWidget* m_titleBar;
    QColor m_primaryColor = QColor("#87CEEB");    // 天蓝色
    QColor m_secondaryColor = QColor("#7CFC00");  // 草绿色
    QColor m_accentColor = QColor("#FF69B4");     // 粉红色
};
```

##### ModernButton（现代化按钮）
```cpp
// 文件：src/qt-ui/components/ModernButton.h
class ModernButton : public QPushButton {
    Q_OBJECT
public:
    enum ColorScheme {
        Primary,    // 天蓝色
        Secondary,  // 草绿色
        Accent      // 粉红色
    };
    
    ModernButton(const QString& text, ColorScheme scheme = Primary);
};
```

##### ModernTitleBar（现代化标题栏）
```cpp
// 文件：src/qt-ui/components/ModernTitleBar.h
class ModernTitleBar : public QWidget {
    Q_OBJECT
public:
    ModernTitleBar(QWidget *parent = nullptr);
    void setTitle(const QString& title);
    
signals:
    void closeClicked();
    void minimizeClicked();
    void maximizeClicked();
};
```

#### 1.2 创建组件库

**任务清单**：
- [ ] ModernWindow - 窗口基类
- [ ] ModernButton - 按钮
- [ ] ModernTitleBar - 标题栏
- [ ] ModernTextEdit - 文本框
- [ ] ModernListView - 列表视图
- [ ] ModernMenu - 菜单
- [ ] ModernDialog - 对话框
- [ ] ModernProgressBar - 进度条
- [ ] ModernScrollBar - 滚动条
- [ ] ModernTabWidget - 标签页

---

### 阶段 2：系统组件迁移（2-3 个月）

#### 2.1 Explorer（文件管理器）

**优先级**：⭐⭐⭐⭐⭐ 最高

**文件位置**：
- 原始：`src/reactos/base/shell/explorer/`
- Qt 版本：`src/qt-ui/apps/explorer/`

**实施步骤**：

1. **创建 QtExplorer 项目**
```cmake
# src/qt-ui/apps/explorer/CMakeLists.txt
project(QtExplorer)

add_executable(QtExplorer
    main.cpp
    ExplorerWindow.cpp
    FileListView.cpp
    NavigationTree.cpp
    AddressBar.cpp
)

target_link_libraries(QtExplorer
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    ModernComponents  # 我们的组件库
)
```

2. **主窗口设计**
```cpp
// ExplorerWindow.cpp
class ExplorerWindow : public ModernWindow {
public:
    ExplorerWindow() {
        setWindowTitle("文件资源管理器");
        
        // 天蓝色到粉红色渐变背景
        setupGradientBackground();
        
        // 创建布局
        createToolbar();      // 工具栏
        createNavigationPane(); // 左侧导航
        createFileView();     // 文件视图
        createStatusBar();    // 状态栏
    }
};
```

3. **配色应用**
```cpp
void ExplorerWindow::setupGradientBackground() {
    // 天蓝色 → 草绿色 → 粉红色渐变
    QLinearGradient gradient(0, 0, width(), height());
    gradient.setColorAt(0, QColor("#87CEEB"));
    gradient.setColorAt(0.5, QColor("#7CFC00"));
    gradient.setColorAt(1, QColor("#FF69B4"));
    
    setBackgroundGradient(gradient);
}

void ExplorerWindow::createToolbar() {
    // 天蓝色按钮
    addToolbarButton("后退", ModernButton::Primary);
    addToolbarButton("前进", ModernButton::Primary);
    addToolbarButton("上一级", ModernButton::Primary);
    
    // 草绿色按钮
    addToolbarButton("新建文件夹", ModernButton::Secondary);
    
    // 粉红色按钮
    addToolbarButton("删除", ModernButton::Accent);
}
```

**时间**：3 周

#### 2.2 任务栏（Taskbar）

**优先级**：⭐⭐⭐⭐⭐ 最高

**文件位置**：
- Qt 版本：`src/qt-ui/shell/taskbar/`

**实施步骤**：

1. **创建 QtTaskbar**
```cpp
// QtTaskbar.cpp
class QtTaskbar : public QWidget {
public:
    QtTaskbar() {
        // 固定在屏幕底部
        setWindowFlags(Qt::FramelessWindowHint | 
                      Qt::WindowStaysOnTopHint);
        
        // 半透明背景（天蓝色）
        setStyleSheet(R"(
            QWidget {
                background-color: rgba(135, 206, 235, 0.8);
                border-top: 2px solid #7CFC00;
            }
        )");
        
        createLayout();
    }
    
private:
    void createLayout() {
        QHBoxLayout* layout = new QHBoxLayout(this);
        
        // 开始按钮（草绿色）
        m_startButton = new ModernButton("⊞ 开始", 
                                        ModernButton::Secondary);
        layout->addWidget(m_startButton);
        
        // 任务按钮区域
        m_taskArea = new QWidget;
        layout->addWidget(m_taskArea, 1);
        
        // 系统托盘（粉红色图标）
        m_systemTray = new SystemTrayWidget;
        layout->addWidget(m_systemTray);
        
        // 时钟
        m_clock = new ClockWidget;
        layout->addWidget(m_clock);
    }
};
```

**时间**：2 周

#### 2.3 开始菜单（Start Menu）

**优先级**：⭐⭐⭐⭐⭐ 最高

**实施步骤**：

```cpp
// StartMenu.cpp
class StartMenu : public QWidget {
public:
    StartMenu() {
        setWindowFlags(Qt::Popup | Qt::FramelessWindowHint);
        
        // 渐变背景
        setupGradient();
        
        // 创建布局
        createUserPanel();      // 用户信息（天蓝色）
        createProgramList();    // 程序列表
        createPowerButtons();   // 电源按钮（粉红色）
    }
    
private:
    void setupGradient() {
        QLinearGradient gradient(0, 0, 0, height());
        gradient.setColorAt(0, QColor("#87CEEB"));
        gradient.setColorAt(0.5, QColor("#7CFC00"));
        gradient.setColorAt(1, QColor("#FF69B4"));
    }
};
```

**时间**：2 周

#### 2.4 控制面板（Control Panel）

**优先级**：⭐⭐⭐⭐

**实施步骤**：

```cpp
// ControlPanel.cpp
class ControlPanel : public ModernWindow {
public:
    ControlPanel() {
        setWindowTitle("控制面板");
        
        // 创建分类卡片
        createCategoryCards();
    }
    
private:
    void createCategoryCards() {
        // 系统和安全（天蓝色卡片）
        addCard("系统和安全", "#87CEEB", {
            "系统", "Windows 更新", "电源选项"
        });
        
        // 网络和 Internet（草绿色卡片）
        addCard("网络和 Internet", "#7CFC00", {
            "网络状态", "Wi-Fi", "以太网"
        });
        
        // 硬件和声音（粉红色卡片）
        addCard("硬件和声音", "#FF69B4", {
            "设备和打印机", "声音", "显示"
        });
    }
};
```

**时间**：2 周

#### 2.5 记事本（Notepad）

**优先级**：⭐⭐⭐

**实施步骤**：

```cpp
// QtNotepad.cpp
class QtNotepad : public ModernWindow {
public:
    QtNotepad() {
        setWindowTitle("记事本");
        
        // 创建文本编辑器
        m_textEdit = new QTextEdit;
        m_textEdit->setStyleSheet(R"(
            QTextEdit {
                background-color: white;
                border: 2px solid #87CEEB;
                border-radius: 8px;
                padding: 10px;
            }
        )");
        
        setCentralWidget(m_textEdit);
        
        // 创建菜单栏
        createMenuBar();
    }
    
private:
    void createMenuBar() {
        // 文件菜单（天蓝色）
        QMenu* fileMenu = menuBar()->addMenu("文件");
        fileMenu->setStyleSheet("background-color: #87CEEB;");
        
        // 编辑菜单（草绿色）
        QMenu* editMenu = menuBar()->addMenu("编辑");
        editMenu->setStyleSheet("background-color: #7CFC00;");
        
        // 格式菜单（粉红色）
        QMenu* formatMenu = menuBar()->addMenu("格式");
        formatMenu->setStyleSheet("background-color: #FF69B4;");
    }
};
```

**时间**：1 周

#### 2.6 计算器（Calculator）

**优先级**：⭐⭐⭐

**实施步骤**：

```cpp
// QtCalculator.cpp
class QtCalculator : public ModernWindow {
public:
    QtCalculator() {
        setWindowTitle("计算器");
        setFixedSize(320, 480);
        
        createDisplay();
        createButtons();
    }
    
private:
    void createButtons() {
        // 数字按钮（天蓝色）
        for (int i = 0; i <= 9; i++) {
            addButton(QString::number(i), ModernButton::Primary);
        }
        
        // 运算符按钮（草绿色）
        addButton("+", ModernButton::Secondary);
        addButton("-", ModernButton::Secondary);
        addButton("×", ModernButton::Secondary);
        addButton("÷", ModernButton::Secondary);
        
        // 等号按钮（粉红色）
        addButton("=", ModernButton::Accent);
    }
};
```

**时间**：1 周

---

### 阶段 3：系统集成（1 个月）

#### 3.1 启动选择器

**创建启动选择器**，让用户选择使用传统 UI 还是现代 UI：

```cpp
// UISelector.cpp
class UISelector : public QDialog {
public:
    UISelector() {
        setWindowTitle("选择界面风格");
        
        QVBoxLayout* layout = new QVBoxLayout(this);
        
        // 标题
        QLabel* title = new QLabel("选择您喜欢的界面风格");
        layout->addWidget(title);
        
        // 传统 UI 按钮
        QPushButton* classicBtn = new QPushButton("传统界面");
        classicBtn->setStyleSheet("background-color: #808080;");
        connect(classicBtn, &QPushButton::clicked, [this]() {
            launchClassicUI();
        });
        layout->addWidget(classicBtn);
        
        // 现代 UI 按钮（渐变）
        QPushButton* modernBtn = new QPushButton("现代界面");
        modernBtn->setStyleSheet(R"(
            QPushButton {
                background: qlineargradient(
                    x1:0, y1:0, x2:1, y2:1,
                    stop:0 #87CEEB,
                    stop:0.5 #7CFC00,
                    stop:1 #FF69B4
                );
                color: white;
                font-weight: bold;
                padding: 20px;
                border-radius: 10px;
            }
        )");
        connect(modernBtn, &QPushButton::clicked, [this]() {
            launchModernUI();
        });
        layout->addWidget(modernBtn);
    }
    
private:
    void launchClassicUI() {
        // 启动传统 Explorer
        QProcess::startDetached("explorer.exe");
        accept();
    }
    
    void launchModernUI() {
        // 启动 Qt Explorer
        QProcess::startDetached("QtExplorer.exe");
        accept();
    }
};
```

#### 3.2 配置系统

**创建配置文件**：`C:\ReactOS\qt-ui-config.ini`

```ini
[UI]
Theme=Modern
ColorScheme=SkyBlueGreenPink

[Colors]
Primary=#87CEEB
Secondary=#7CFC00
Accent=#FF69B4

[Components]
Explorer=Qt
Taskbar=Qt
StartMenu=Qt
ControlPanel=Qt
Notepad=Qt
Calculator=Qt
```

#### 3.3 系统启动集成

**修改启动流程**：

```cpp
// 在 ReactOS 启动时
void InitializeShell() {
    // 读取配置
    QSettings settings("C:/ReactOS/qt-ui-config.ini");
    QString theme = settings.value("UI/Theme", "Classic").toString();
    
    if (theme == "Modern") {
        // 启动 Qt 组件
        startQtTaskbar();
        startQtExplorer();
    } else {
        // 启动传统组件
        startClassicShell();
    }
}
```

---

### 阶段 4：测试和优化（1 个月）

#### 4.1 功能测试

**测试清单**：
- [ ] 所有窗口正常显示
- [ ] 渐变背景正确渲染
- [ ] 按钮颜色正确
- [ ] 动画流畅
- [ ] 拖动窗口正常
- [ ] 最小化/最大化/关闭正常
- [ ] 菜单功能正常
- [ ] 文件操作正常

#### 4.2 性能测试

**测试项目**：
- 启动时间
- 内存占用
- CPU 使用率
- 渲染帧率
- 响应速度

#### 4.3 兼容性测试

**测试项目**：
- Win32 应用兼容性
- 传统 UI 切换
- 多显示器支持
- 不同分辨率

---

## 项目结构

```
ReactOS/
├── src/
│   ├── reactos/              # 原始 ReactOS 代码（保留）
│   │   ├── base/
│   │   ├── dll/
│   │   └── ...
│   │
│   └── qt-ui/                # Qt 现代化 UI（新增）
│       ├── components/       # 组件库
│       │   ├── ModernWindow.h
│       │   ├── ModernWindow.cpp
│       │   ├── ModernButton.h
│       │   ├── ModernButton.cpp
│       │   ├── ModernTitleBar.h
│       │   ├── ModernTitleBar.cpp
│       │   └── ...
│       │
│       ├── apps/             # 应用程序
│       │   ├── explorer/     # Qt 文件管理器
│       │   ├── notepad/      # Qt 记事本
│       │   ├── calculator/   # Qt 计算器
│       │   └── ...
│       │
│       ├── shell/            # Shell 组件
│       │   ├── taskbar/      # Qt 任务栏
│       │   ├── startmenu/    # Qt 开始菜单
│       │   └── ...
│       │
│       └── themes/           # 主题配置
│           ├── SkyBlueGreenPink.qss
│           └── colors.ini
│
├── build/
└── CMakeLists.txt
```

---

## CMake 配置

```cmake
# 主 CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(ReactOS_Modern)

# Qt 配置
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

# 选项
option(BUILD_QT_UI "构建 Qt 现代化 UI" ON)
option(BUILD_CLASSIC_UI "构建传统 UI" ON)

# 传统 ReactOS
if(BUILD_CLASSIC_UI)
    add_subdirectory(src/reactos)
endif()

# Qt 现代化 UI
if(BUILD_QT_UI)
    add_subdirectory(src/qt-ui)
endif()
```

---

## 时间表

### 总时间：5-6 个月

| 阶段 | 任务 | 时间 | 人员 |
|------|------|------|------|
| 1 | 组件库开发 | 1 个月 | 2-3 人 |
| 2 | 系统组件迁移 | 2-3 个月 | 3-4 人 |
| 3 | 系统集成 | 1 个月 | 2 人 |
| 4 | 测试和优化 | 1 个月 | 2-3 人 |

---

## 下一步行动

### 立即开始（本周）

1. **创建项目结构**
```powershell
# 创建目录
mkdir src\qt-ui\components
mkdir src\qt-ui\apps
mkdir src\qt-ui\shell
mkdir src\qt-ui\themes
```

2. **复制演示代码**
```powershell
# 将 Material3Demo 作为模板
Copy-Item demos\Material3Demo\modernwindow.* src\qt-ui\components\
```

3. **创建组件库**
- 提取 ModernWindow 基类
- 提取 ModernButton 类
- 提取 ModernTitleBar 类

### 本月目标

- [ ] 完成组件库基础框架
- [ ] 创建第一个系统组件（Explorer）
- [ ] 测试基本功能

---

## 配色指南

### 主色调使用

**天蓝色 (#87CEEB)**：
- 主要按钮
- 标题栏
- 链接
- 选中状态

**草绿色 (#7CFC00)**：
- 次要按钮
- 成功提示
- 确认操作
- 活动状态

**粉红色 (#FF69B4)**：
- 强调按钮
- 警告/删除操作
- 重要提示
- 特殊状态

### 渐变使用

**窗口背景**：
```cpp
QLinearGradient gradient(0, 0, width(), height());
gradient.setColorAt(0, QColor("#87CEEB"));    // 天蓝色
gradient.setColorAt(0.5, QColor("#7CFC00"));  // 草绿色
gradient.setColorAt(1, QColor("#FF69B4"));    // 粉红色
```

**按钮悬停**：
```cpp
// 天蓝色按钮悬停 → 更亮的天蓝色
QColor("#A0D8F0")

// 草绿色按钮悬停 → 更亮的草绿色
QColor("#90FF20")

// 粉红色按钮悬停 → 更亮的粉红色
QColor("#FF85C8")
```

---

## 成功标准

### 功能标准
- ✅ 所有系统组件都有 Qt 版本
- ✅ 用户可以选择传统/现代 UI
- ✅ Win32 应用 100% 兼容
- ✅ 性能不低于传统 UI

### 视觉标准
- ✅ 所有窗口使用统一配色
- ✅ 渐变背景流畅美观
- ✅ 动画效果流畅（60fps）
- ✅ 圆角和阴影正确渲染

### 用户体验标准
- ✅ 启动时间 < 5 秒
- ✅ 操作响应 < 100ms
- ✅ 内存占用合理
- ✅ 用户满意度 > 80%

---

**文档版本**：1.0  
**最后更新**：2025-10-30  
**配色方案**：天蓝色 + 草绿色 + 粉红色  
**状态**：准备开始实施

