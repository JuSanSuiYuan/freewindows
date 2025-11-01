# 创建 Material 3 演示项目
# 快速创建第一个 Qt Material 3 窗口

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "Material3Demo",
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectDir = "demos"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "创建 Material 3 演示项目" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 创建项目目录
$fullPath = Join-Path $ProjectDir $ProjectName
if (Test-Path $fullPath) {
    Write-Host "警告：项目目录已存在，将覆盖" -ForegroundColor Yellow
    Remove-Item -Path $fullPath -Recurse -Force
}

New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
Write-Host "✓ 创建项目目录: $fullPath" -ForegroundColor Green

# 创建 CMakeLists.txt
$cmakeContent = @"
cmake_minimum_required(VERSION 3.20)
project($ProjectName)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 查找 Qt
find_package(Qt6 COMPONENTS Core Gui Widgets QUIET)
if(NOT Qt6_FOUND)
    find_package(Qt5 COMPONENTS Core Gui Widgets REQUIRED)
endif()

# 源文件
add_executable($ProjectName
    main.cpp
    modernwindow.h
    modernwindow.cpp
)

# 链接 Qt
if(Qt6_FOUND)
    target_link_libraries($ProjectName
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
    )
else()
    target_link_libraries($ProjectName
        Qt5::Core
        Qt5::Gui
        Qt5::Widgets
    )
endif()

# Windows 特定设置
if(WIN32)
    set_target_properties($ProjectName PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()
"@

$cmakeContent | Out-File -FilePath "$fullPath\CMakeLists.txt" -Encoding UTF8
Write-Host "✓ 创建 CMakeLists.txt" -ForegroundColor Green

# 创建 main.cpp
$mainContent = @"
#include <QApplication>
#include "modernwindow.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    
    // 设置应用信息
    app.setApplicationName("Material 3 Demo");
    app.setApplicationVersion("1.0");
    
    // 创建并显示窗口
    ModernWindow window;
    window.resize(800, 600);
    window.show();
    
    return app.exec();
}
"@

$mainContent | Out-File -FilePath "$fullPath\main.cpp" -Encoding UTF8
Write-Host "✓ 创建 main.cpp" -ForegroundColor Green

# 创建 modernwindow.h
$headerContent = @"
#ifndef MODERNWINDOW_H
#define MODERNWINDOW_H

#include <QMainWindow>
#include <QPushButton>
#include <QVBoxLayout>
#include <QLabel>
#include <QPainter>
#include <QGraphicsDropShadowEffect>
#include <QMouseEvent>
#include <QPropertyAnimation>

class ModernWindow : public QMainWindow {
    Q_OBJECT
    
public:
    ModernWindow(QWidget *parent = nullptr);
    ~ModernWindow() = default;
    
protected:
    void paintEvent(QPaintEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    
private:
    void setupUI();
    QPushButton* createMaterial3Button(const QString& text, const QString& color);
    void createTitleBar();
    
    QPoint m_dragPosition;
    QWidget* m_titleBar;
};

#endif // MODERNWINDOW_H
"@

$headerContent | Out-File -FilePath "$fullPath\modernwindow.h" -Encoding UTF8
Write-Host "✓ 创建 modernwindow.h" -ForegroundColor Green

# 创建 modernwindow.cpp
$cppContent = @"
#include "modernwindow.h"
#include <QLinearGradient>
#include <QPainterPath>
#include <QHBoxLayout>

ModernWindow::ModernWindow(QWidget *parent)
    : QMainWindow(parent), m_titleBar(nullptr) {
    
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
    
    // 主布局
    QVBoxLayout* mainLayout = new QVBoxLayout(central);
    mainLayout->setContentsMargins(0, 0, 0, 0);
    mainLayout->setSpacing(0);
    
    // 创建标题栏
    createTitleBar();
    mainLayout->addWidget(m_titleBar);
    
    // 内容区域
    QWidget* content = new QWidget;
    QVBoxLayout* contentLayout = new QVBoxLayout(content);
    contentLayout->setContentsMargins(20, 20, 20, 20);
    contentLayout->setSpacing(16);
    
    // 标题
    QLabel* title = new QLabel("Material 3 演示");
    title->setStyleSheet(R"(
        QLabel {
            color: white;
            font-size: 32px;
            font-weight: bold;
        }
    )");
    contentLayout->addWidget(title);
    
    // 副标题
    QLabel* subtitle = new QLabel("使用 Qt 实现的现代化界面");
    subtitle->setStyleSheet(R"(
        QLabel {
            color: rgba(255, 255, 255, 0.8);
            font-size: 16px;
        }
    )");
    contentLayout->addWidget(subtitle);
    
    contentLayout->addSpacing(20);
    
    // 添加按钮
    contentLayout->addWidget(createMaterial3Button("主要按钮", "#6750A4"));
    contentLayout->addWidget(createMaterial3Button("次要按钮", "#625B71"));
    contentLayout->addWidget(createMaterial3Button("第三按钮", "#7D5260"));
    
    contentLayout->addStretch();
    
    mainLayout->addWidget(content);
}

void ModernWindow::createTitleBar() {
    m_titleBar = new QWidget;
    m_titleBar->setFixedHeight(40);
    m_titleBar->setStyleSheet("background-color: rgba(0, 0, 0, 0.2);");
    
    QHBoxLayout* layout = new QHBoxLayout(m_titleBar);
    layout->setContentsMargins(10, 0, 10, 0);
    
    // 标题
    QLabel* titleLabel = new QLabel("Material 3 Demo");
    titleLabel->setStyleSheet("color: white; font-weight: bold;");
    layout->addWidget(titleLabel);
    
    layout->addStretch();
    
    // 关闭按钮
    QPushButton* closeBtn = new QPushButton("×");
    closeBtn->setFixedSize(40, 40);
    closeBtn->setStyleSheet(R"(
        QPushButton {
            background-color: transparent;
            color: white;
            border: none;
            font-size: 24px;
        }
        QPushButton:hover {
            background-color: rgba(255, 0, 0, 0.5);
        }
    )");
    connect(closeBtn, &QPushButton::clicked, this, &QWidget::close);
    layout->addWidget(closeBtn);
}

QPushButton* ModernWindow::createMaterial3Button(const QString& text, const QString& color) {
    QPushButton* button = new QPushButton(text);
    
    // Material 3 样式
    QString style = QString(R"(
        QPushButton {
            background-color: %1;
            color: white;
            border: none;
            border-radius: 20px;
            padding: 12px 24px;
            font-size: 16px;
            font-weight: 500;
        }
        QPushButton:hover {
            background-color: %2;
        }
        QPushButton:pressed {
            background-color: %3;
        }
    )").arg(color)
       .arg(adjustColor(color, 10))
       .arg(adjustColor(color, -10));
    
    button->setStyleSheet(style);
    button->setCursor(Qt::PointingHandCursor);
    
    // 添加阴影
    QGraphicsDropShadowEffect* shadow = new QGraphicsDropShadowEffect;
    shadow->setBlurRadius(8);
    shadow->setColor(QColor(0, 0, 0, 76));
    shadow->setOffset(0, 2);
    button->setGraphicsEffect(shadow);
    
    // 点击动画
    connect(button, &QPushButton::clicked, [button]() {
        QPropertyAnimation* anim = new QPropertyAnimation(button, "geometry");
        anim->setDuration(100);
        anim->setEasingCurve(QEasingCurve::OutCubic);
        
        QRect startGeometry = button->geometry();
        QRect endGeometry = startGeometry.adjusted(2, 2, -2, -2);
        
        anim->setStartValue(startGeometry);
        anim->setKeyValueAt(0.5, endGeometry);
        anim->setEndValue(startGeometry);
        anim->start(QAbstractAnimation::DeleteWhenStopped);
    });
    
    return button;
}

QString adjustColor(const QString& color, int amount) {
    QColor c(color);
    int r = qBound(0, c.red() + amount, 255);
    int g = qBound(0, c.green() + amount, 255);
    int b = qBound(0, c.blue() + amount, 255);
    return QString("#%1%2%3")
        .arg(r, 2, 16, QChar('0'))
        .arg(g, 2, 16, QChar('0'))
        .arg(b, 2, 16, QChar('0'));
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

void ModernWindow::mousePressEvent(QMouseEvent *event) {
    if (event->button() == Qt::LeftButton && m_titleBar) {
        QPoint pos = event->pos();
        if (pos.y() < m_titleBar->height()) {
            m_dragPosition = event->globalPos() - frameGeometry().topLeft();
            event->accept();
        }
    }
}

void ModernWindow::mouseMoveEvent(QMouseEvent *event) {
    if (event->buttons() & Qt::LeftButton && !m_dragPosition.isNull()) {
        move(event->globalPos() - m_dragPosition);
        event->accept();
    }
}
"@

$cppContent | Out-File -FilePath "$fullPath\modernwindow.cpp" -Encoding UTF8
Write-Host "✓ 创建 modernwindow.cpp" -ForegroundColor Green

# 创建 README
$readmeContent = @"
# $ProjectName

Material 3 风格的 Qt 演示项目

## 构建

### 使用 CMake

``````powershell
# 配置
cmake -B build -G Ninja

# 构建
cmake --build build

# 运行
.\build\$ProjectName.exe
``````

### 使用 Qt Creator

1. 打开 Qt Creator
2. 文件 → 打开文件或项目
3. 选择 CMakeLists.txt
4. 点击构建并运行

## 特性

- ✅ 圆角窗口
- ✅ Material 3 渐变背景
- ✅ 带阴影的按钮
- ✅ 流畅动画
- ✅ 可拖动标题栏
- ✅ 现代化外观

## 技术栈

- Qt 5/6
- CMake
- C++17

---

创建时间：$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

$readmeContent | Out-File -FilePath "$fullPath\README.md" -Encoding UTF8
Write-Host "✓ 创建 README.md" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "项目创建完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "项目位置: $fullPath" -ForegroundColor Green
Write-Host ""

Write-Host "下一步：" -ForegroundColor Yellow
Write-Host ""
Write-Host "方法 1：使用 Qt Creator（推荐）" -ForegroundColor Cyan
Write-Host "  1. 打开 Qt Creator" -ForegroundColor White
Write-Host "  2. 文件 → 打开文件或项目" -ForegroundColor White
Write-Host "  3. 选择: $fullPath\CMakeLists.txt" -ForegroundColor White
Write-Host "  4. 点击 '配置项目'" -ForegroundColor White
Write-Host "  5. 点击 '运行' (绿色播放按钮)" -ForegroundColor White
Write-Host ""

Write-Host "方法 2：使用命令行" -ForegroundColor Cyan
Write-Host "  cd $fullPath" -ForegroundColor White
Write-Host "  cmake -B build -G Ninja" -ForegroundColor White
Write-Host "  cmake --build build" -ForegroundColor White
Write-Host "  .\build\$ProjectName.exe" -ForegroundColor White
Write-Host ""

Write-Host "提示：如果找不到 Qt，需要设置 CMAKE_PREFIX_PATH" -ForegroundColor Yellow
Write-Host "  例如：cmake -B build -DCMAKE_PREFIX_PATH=D:\QT\6.x.x\msvc2019_64" -ForegroundColor Gray
Write-Host ""

