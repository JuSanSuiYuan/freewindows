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
    
    // 添加按钮 - 天蓝色、草绿色、粉红色
    contentLayout->addWidget(createMaterial3Button("天蓝色按钮", "#87CEEB"));
    contentLayout->addWidget(createMaterial3Button("草绿色按钮", "#7CFC00"));
    contentLayout->addWidget(createMaterial3Button("粉红色按钮", "#FF69B4"));
    
    contentLayout->addStretch();
    
    mainLayout->addWidget(content);
}

void ModernWindow::createTitleBar() {
    m_titleBar = new QWidget;
    m_titleBar->setFixedHeight(40);
    m_titleBar->setStyleSheet("background-color: rgba(0, 0, 0, 0.2);");
    
    QHBoxLayout* layout = new QHBoxLayout(m_titleBar);
    layout->setContentsMargins(5, 0, 5, 0);
    layout->setSpacing(0);
    
    // 创建按钮的辅助函数
    auto createButton = [](const QString& text, const QString& tooltip, const QColor& hoverColor) -> QPushButton* {
        QPushButton* btn = new QPushButton(text);
        btn->setFixedSize(40, 40);
        btn->setToolTip(tooltip);
        
        QString hoverColorStr = QString("rgba(%1, %2, %3, 0.5)")
            .arg(hoverColor.red())
            .arg(hoverColor.green())
            .arg(hoverColor.blue());
        
        btn->setStyleSheet(QString(R"(
            QPushButton {
                background-color: transparent;
                color: white;
                border: none;
                font-size: 20px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: %1;
                border-radius: 4px;
            }
        )").arg(hoverColorStr));
        
        return btn;
    };
    
    // 左侧按钮组 (macOS 风格)
    QPushButton* leftCloseBtn = createButton("×", "关闭", QColor(255, 0, 0));
    connect(leftCloseBtn, &QPushButton::clicked, this, &QWidget::close);
    layout->addWidget(leftCloseBtn);
    
    QPushButton* leftMinBtn = createButton("−", "最小化", QColor(255, 255, 0));
    connect(leftMinBtn, &QPushButton::clicked, this, &QWidget::showMinimized);
    layout->addWidget(leftMinBtn);
    
    QPushButton* leftMaxBtn = createButton("□", "最大化/还原", QColor(0, 255, 0));
    connect(leftMaxBtn, &QPushButton::clicked, [this]() {
        if (isMaximized()) {
            showNormal();
        } else {
            showMaximized();
        }
    });
    layout->addWidget(leftMaxBtn);
    
    layout->addSpacing(10);
    
    // 中间标题
    QLabel* titleLabel = new QLabel("◯ Material 3 Demo");
    titleLabel->setStyleSheet("color: white; font-weight: bold; font-size: 14px;");
    layout->addWidget(titleLabel);
    
    layout->addStretch();
    
    // 右侧按钮组 (Windows 风格)
    QPushButton* rightMinBtn = createButton("−", "最小化", QColor(128, 128, 128));
    connect(rightMinBtn, &QPushButton::clicked, this, &QWidget::showMinimized);
    layout->addWidget(rightMinBtn);
    
    QPushButton* rightMaxBtn = createButton("□", "最大化/还原", QColor(128, 128, 128));
    connect(rightMaxBtn, &QPushButton::clicked, [this]() {
        if (isMaximized()) {
            showNormal();
        } else {
            showMaximized();
        }
    });
    layout->addWidget(rightMaxBtn);
    
    QPushButton* rightCloseBtn = createButton("×", "关闭", QColor(255, 0, 0));
    connect(rightCloseBtn, &QPushButton::clicked, this, &QWidget::close);
    layout->addWidget(rightCloseBtn);
}

QPushButton* ModernWindow::createMaterial3Button(const QString& text, const QString& color) {
    QPushButton* button = new QPushButton(text);
    
    // 辅助函数：调整颜色亮度
    auto adjustColor = [](const QString& colorStr, int amount) -> QString {
        QColor c(colorStr);
        int r = qBound(0, c.red() + amount, 255);
        int g = qBound(0, c.green() + amount, 255);
        int b = qBound(0, c.blue() + amount, 255);
        return QString("#%1%2%3")
            .arg(r, 2, 16, QChar('0'))
            .arg(g, 2, 16, QChar('0'))
            .arg(b, 2, 16, QChar('0'));
    };
    
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

void ModernWindow::paintEvent(QPaintEvent *event) {
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    
    // 天蓝色到草绿色渐变背景
    QLinearGradient gradient(0, 0, width(), height());
    gradient.setColorAt(0, QColor("#87CEEB"));  // 天蓝色
    gradient.setColorAt(0.5, QColor("#7CFC00")); // 草绿色（中间）
    gradient.setColorAt(1, QColor("#FF69B4"));  // 粉红色
    
    // 圆角矩形
    QPainterPath path;
    path.addRoundedRect(rect(), 12, 12);
    
    painter.fillPath(path, gradient);
}

void ModernWindow::mousePressEvent(QMouseEvent *event) {
    if (event->button() == Qt::LeftButton && m_titleBar) {
        QPoint pos = event->pos();
        if (pos.y() < m_titleBar->height()) {
            m_dragPosition = event->globalPosition().toPoint() - frameGeometry().topLeft();
            event->accept();
        }
    }
}

void ModernWindow::mouseMoveEvent(QMouseEvent *event) {
    if (event->buttons() & Qt::LeftButton && !m_dragPosition.isNull()) {
        move(event->globalPosition().toPoint() - m_dragPosition);
        event->accept();
    }
}
