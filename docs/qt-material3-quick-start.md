# Qt Material 3 快速开始指南

## 立即开始

这个指南将帮助你在 **30 分钟内**创建第一个 Material 3 风格的 Qt 窗口。

---

## 步骤 1：安装 Qt（5 分钟）

### 下载 Qt

访问：https://www.qt.io/download

**推荐版本**：Qt 6.9 或更高

**需要的组件**：
- ✅ Qt 6.9 for MSVC 2022
- ✅ Qt Creator
- ✅ CMake
- ✅ Ninja

### 验证安装

```powershell
qmake --version
# 应该显示：QMake version 3.1, Using Qt version 6.9.x
```

---

## 步骤 2：创建项目（5 分钟）

### 使用 Qt Creator

1. 打开 Qt Creator
2. 文件 → 新建项目
3. 选择 "Qt Widgets Application"
4. 项目名称：`Material3Demo`
5. 构建系统：CMake
6. 完成

### 或使用命令行

```powershell
# 创建项目目录
mkdir Material3Demo
cd Material3Demo

# 创建 CMakeLists.txt
@"
cmake_minimum_required(VERSION 3.20)
project(Material3Demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

add_executable(Material3Demo
    main.cpp
    modernwindow.h
    modernwindow.cpp
)

target_link_libraries(Material3Demo
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
)
"@ | Out-File -FilePath CMakeLists.txt
```

---

## 步骤 3：创建 Material 3 窗口（10 分钟）

### main.cpp

```cpp
#include <QApplication>
#include "modernwindow.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    
    ModernWindow window;
    window.resize(800, 600);
    window.show();
    
    return app.exec();
}
```

### modernwindow.h

```cpp
#ifndef MODERNWINDOW_H
#define MODERNWINDOW_H

#include <QMainWindow>
#include <QPushButton>
#include <QVBoxLayout>
#include <QLabel>
#include <QPainter>
#include <QGraphicsDropShadowEffect>

class ModernWindow : public QMainWindow {
    Q_OBJECT
    
public:
    ModernWindow(QWidget *parent = nullptr);
    
protected:
    void paintEvent(QPaintEvent *event) override;
    
private:
    void setupUI();
    QPushButton* createMaterial3Button(const QString& text);
};

#endif // MODERNWINDOW_H
```

### modernwindow.cpp

```cpp
#include "modernwindow.h"
#include <QLinearGradient>
#include <QPainterPath>

ModernWindow::ModernWindow(QWidget *parent)
    : QMainWindow(parent) {
    
    // 无边框窗口
    setWindowFlags(Qt::FramelessWindowHint);
    
    // 透明背景
    setAttribute(Qt::WA_TranslucentBackground);
    
    // 设置 UI
    setupUI();
    
    // 添加窗口阴影
    QGraphicsDropShadowEffect* shadow = new QGraphicsDropShadowEffect;
    shadow->setBlurRadius(20);
    shadow->setColor(QColor(0, 0, 0, 100));
    shadow->setOffset(0, 4);
    setGraphicsEffect(shadow);
}

void ModernWindow::setupUI() {
    // 中央部件
    QWidget* central = new QWidget;
    setCentralWidget(central);
    
    // 布局
    QVBoxLayout* layout = new QVBoxLayout(central);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(16);
    
    // 标题
    QLabel* title = new QLabel("Material 3 Demo");
    title->setStyleSheet(R"(
        QLabel {
            color: white;
            font-size: 32px;
            font-weight: bold;
        }
    )");
    layout->addWidget(title);
    
    // 添加一些按钮
    layout->addWidget(createMaterial3Button("按钮 1"));
    layout->addWidget(createMaterial3Button("按钮 2"));
    layout->addWidget(createMaterial3Button("按钮 3"));
    
    layout->addStretch();
}

QPushButton* ModernWindow::createMaterial3Button(const QString& text) {
    QPushButton* button = new QPushButton(text);
    
    // Material 3 样式
    button->setStyleSheet(R"(
        QPushButton {
            background-color: #6750A4;
            color: white;
            border: none;
            border-radius: 20px;
            padding: 12px 24px;
            font-size: 16px;
            font-weight: 500;
        }
        QPushButton:hover {
            background-color: #7965AF;
        }
        QPushButton:pressed {
            background-color: #5A3D8F;
        }
    )");
    
    // 添加阴影
    QGraphicsDropShadowEffect* shadow = new QGraphicsDropShadowEffect;
    shadow->setBlurRadius(8);
    shadow->setColor(QColor(0, 0, 0, 76));
    shadow->setOffset(0, 2);
    button->setGraphicsEffect(shadow);
    
    return button;
}

void ModernWindow::paintEvent(QPaintEvent *event) {
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    
    // Material 3 渐变背景
    QLinearGradient gradient(0, 0, width(), height());
    gradient.setColorAt(0, QColor("#6750A4"));  // Material 3 主色
    gradient.setColorAt(1, QColor("#4F378B"));  // Material 3 主容器色
    
    // 圆角矩形
    QPainterPath path;
    path.addRoundedRect(rect(), 12, 12);
    
    painter.fillPath(path, gradient);
}
```

---

## 步骤 4：构建和运行（5 分钟）

### 使用 Qt Creator

1. 点击 "构建" 按钮（锤子图标）
2. 点击 "运行" 按钮（播放图标）

### 使用命令行

```powershell
# 配置
cmake -B build -G Ninja

# 构建
cmake --build build

# 运行
.\build\Material3Demo.exe
```

---

## 步骤 5：添加动画（5 分钟）

### 修改 modernwindow.cpp

在 `createMaterial3Button` 函数中添加：

```cpp
QPushButton* ModernWindow::createMaterial3Button(const QString& text) {
    QPushButton* button = new QPushButton(text);
    
    // ... 现有代码 ...
    
    // 添加悬停动画
    button->installEventFilter(new ButtonAnimator(button));
    
    return button;
}
```

### 创建 ButtonAnimator 类

在 `modernwindow.h` 中添加：

```cpp
class ButtonAnimator : public QObject {
    Q_OBJECT
public:
    ButtonAnimator(QWidget* parent) : QObject(parent), m_widget(parent) {}
    
protected:
    bool eventFilter(QObject* obj, QEvent* event) override {
        if (event->type() == QEvent::Enter) {
            // 悬停动画
            QPropertyAnimation* anim = new QPropertyAnimation(m_widget, "geometry");
            anim->setDuration(150);
            anim->setEasingCurve(QEasingCurve::OutCubic);
            
            QRect newGeometry = m_widget->geometry();
            newGeometry.adjust(-2, -2, 2, 2);
            anim->setEndValue(newGeometry);
            anim->start(QAbstractAnimation::DeleteWhenStopped);
        }
        else if (event->type() == QEvent::Leave) {
            // 恢复动画
            QPropertyAnimation* anim = new QPropertyAnimation(m_widget, "geometry");
            anim->setDuration(150);
            anim->setEasingCurve(QEasingCurve::OutCubic);
            
            QRect newGeometry = m_widget->geometry();
            newGeometry.adjust(2, 2, -2, -2);
            anim->setEndValue(newGeometry);
            anim->start(QAbstractAnimation::DeleteWhenStopped);
        }
        
        return QObject::eventFilter(obj, event);
    }
    
private:
    QWidget* m_widget;
};
```

---

## 结果

你现在应该看到一个：

✅ **圆角窗口**  
✅ **Material 3 渐变背景**  
✅ **带阴影的按钮**  
✅ **流畅的悬停动画**  
✅ **现代化的外观**  

---

## 下一步

### 添加更多组件

1. **标题栏**：
   - 窗口控制按钮
   - 拖动功能
   - 图标和标题

2. **文本框**：
   - Material 3 样式
   - 浮动标签
   - 验证提示

3. **列表**：
   - 卡片式列表
   - 滑动动画
   - 选择效果

### 集成 Vulkan

```cpp
// 创建 Vulkan 窗口
QVulkanInstance vulkanInstance;
vulkanInstance.create();

QVulkanWindow* vulkanWindow = new QVulkanWindow;
vulkanWindow->setVulkanInstance(&vulkanInstance);

// 在 Qt 窗口中嵌入 Vulkan
QWidget* container = QWidget::createWindowContainer(vulkanWindow);
layout->addWidget(container);
```

---

## 完整项目结构

```
Material3Demo/
├── CMakeLists.txt
├── main.cpp
├── modernwindow.h
├── modernwindow.cpp
└── build/
    └── Material3Demo.exe
```

---

## 常见问题

### Q: 窗口没有圆角？

**A**: 确保设置了：
```cpp
setWindowFlags(Qt::FramelessWindowHint);
setAttribute(Qt::WA_TranslucentBackground);
```

### Q: 阴影不显示？

**A**: 检查是否启用了透明背景：
```cpp
setAttribute(Qt::WA_TranslucentBackground);
```

### Q: 动画不流畅？

**A**: 启用抗锯齿：
```cpp
painter.setRenderHint(QPainter::Antialiasing);
```

---

## 性能提示

1. **缓存渐变**：
```cpp
// 在类成员中缓存
QLinearGradient m_cachedGradient;
```

2. **使用 QPixmap 缓存**：
```cpp
QPixmap pixmap(size());
QPainter painter(&pixmap);
// 绘制到 pixmap
```

3. **减少重绘**：
```cpp
update(dirtyRect);  // 只更新需要的区域
```

---

## 总结

在 30 分钟内，你已经：

✅ 安装了 Qt  
✅ 创建了项目  
✅ 实现了 Material 3 窗口  
✅ 添加了动画效果  
✅ 学会了基础技巧  

**下一步**：查看 `docs/qt-vulkan-migration-plan.md` 了解完整的迁移计划！

---

**文档版本**：1.0  
**最后更新**：2025-10-30  
**难度**：⭐⭐☆☆☆ (简单)

