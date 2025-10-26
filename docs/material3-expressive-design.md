# Material 3 Expressive 风格设计方案

## 概述

将 FreeWindows 界面从毛玻璃效果改为 **Google Material 3 Expressive** 风格。

## Material 3 Expressive 特点

### 核心设计语言

**Material 3 Expressive** 特点：
- ✅ 大胆的色彩
- ✅ 动态色彩系统
- ✅ 强烈的阴影和深度
- ✅ 流畅的动画
- ✅ 圆角设计
- ✅ 表面层次感
- ❌ 无毛玻璃效果

### 视觉效果对比

**毛玻璃风格（旧）**：
```
╭─────────────────────────────────────────╮
│ × ─ ○ │    ◯ ReactOS         │ ─ ○ × │
├─────────────────────────────────────────┤
│ [半透明模糊背景]                        │  ← 毛玻璃
├─────────────────────────────────────────┤
```

**Material 3 Expressive（新）**：
```
╭─────────────────────────────────────────╮
│ × ─ ○ │    ◯ ReactOS         │ ─ ○ × │
├─────────────────────────────────────────┤
│ [纯色背景 + 强阴影 + 色彩渐变]          │  ← Material 3
├─────────────────────────────────────────┤
```

---

## 第一部分：色彩系统

### Material 3 动态色彩

**核心色彩**：
```cpp
// Material 3 Expressive 色彩方案
struct Material3Colors {
    // 主色调（Primary）
    QColor primary = QColor("#6750A4");           // 紫色
    QColor onPrimary = QColor("#FFFFFF");         // 白色
    QColor primaryContainer = QColor("#EADDFF");  // 浅紫色
    QColor onPrimaryContainer = QColor("#21005D");
    
    // 次要色（Secondary）
    QColor secondary = QColor("#625B71");         // 灰紫色
    QColor onSecondary = QColor("#FFFFFF");
    QColor secondaryContainer = QColor("#E8DEF8");
    QColor onSecondaryContainer = QColor("#1D192B");
    
    // 第三色（Tertiary）
    QColor tertiary = QColor("#7D5260");          // 玫瑰色
    QColor onTertiary = QColor("#FFFFFF");
    QColor tertiaryContainer = QColor("#FFD8E4");
    QColor onTertiaryContainer = QColor("#31111D");
    
    // 表面色（Surface）
    QColor surface = QColor("#FFFBFE");           // 近白色
    QColor onSurface = QColor("#1C1B1F");         // 深灰色
    QColor surfaceVariant = QColor("#E7E0EC");    // 浅灰紫
    QColor onSurfaceVariant = QColor("#49454F");
    
    // 背景色（Background）
    QColor background = QColor("#FFFBFE");
    QColor onBackground = QColor("#1C1B1F");
    
    // 错误色（Error）
    QColor error = QColor("#B3261E");
    QColor onError = QColor("#FFFFFF");
    QColor errorContainer = QColor("#F9DEDC");
    QColor onErrorContainer = QColor("#410E0B");
    
    // 轮廓色（Outline）
    QColor outline = QColor("#79747E");
    QColor outlineVariant = QColor("#CAC4D0");
};
```

### 深色模式

```cpp
struct Material3ColorsDark {
    QColor primary = QColor("#D0BCFF");
    QColor onPrimary = QColor("#381E72");
    QColor primaryContainer = QColor("#4F378B");
    QColor onPrimaryContainer = QColor("#EADDFF");
    
    QColor surface = QColor("#1C1B1F");
    QColor onSurface = QColor("#E6E1E5");
    QColor surfaceVariant = QColor("#49454F");
    QColor onSurfaceVariant = QColor("#CAC4D0");
    
    QColor background = QColor("#1C1B1F");
    QColor onBackground = QColor("#E6E1E5");
};
```

---

## 第二部分：窗口设计

### Material 3 窗口

**视觉效果**：
```
╭─────────────────────────────────────────╮
│ × ─ ○ │    ◯ ReactOS         │ ─ ○ × │  ← 纯色标题栏 + 强阴影
├─────────────────────────────────────────┤
│ 文件  编辑  查看  帮助                  │  ← 纯色菜单栏
├─────────────────────────────────────────┤
│                                         │
│  ╭───────╮  ╭───────╮  ╭───────╮      │  ← 浮动按钮 + 强阴影
│  │ 按钮1 │  │ 按钮2 │  │ 按钮3 │      │
│  ╰───────╯  ╰───────╯  ╰───────╯      │
│                                         │
│  [色彩渐变背景]                         │  ← 渐变而非毛玻璃
│                                         │
╰─────────────────────────────────────────╯
```

### 实现代码

```cpp
class Material3Window : public QMainWindow {
public:
    Material3Window(QWidget *parent = nullptr)
        : QMainWindow(parent) {
        
        // 设置窗口属性
        setWindowFlags(Qt::FramelessWindowHint);
        
        // Material 3 不使用透明背景
        // setAttribute(Qt::WA_TranslucentBackground); // 移除
        
        // 创建标题栏
        m_titleBar = new Material3TitleBar(this);
        setMenuWidget(m_titleBar);
        
        // 应用 Material 3 样式
        applyMaterial3Style();
    }
    
private:
    void applyMaterial3Style() {
        // 不使用 DWM 毛玻璃效果
        // 使用纯色 + 阴影
        
        setStyleSheet(R"(
            QMainWindow {
                background-color: #FFFBFE;
                border-radius: 12px;
            }
            
            /* Material 3 强阴影 */
            QMainWindow {
                box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.12),
                           0px 8px 16px rgba(0, 0, 0, 0.08);
            }
        )");
    }
    
    Material3TitleBar *m_titleBar;
};
```

---

## 第三部分：标题栏设计

### Material 3 标题栏

```cpp
class Material3TitleBar : public QWidget {
public:
    Material3TitleBar(QWidget *parent = nullptr)
        : QWidget(parent) {
        
        setFixedHeight(48);  // Material 3 标准高度
        
        QHBoxLayout *layout = new QHBoxLayout(this);
        layout->setContentsMargins(4, 4, 4, 4);
        layout->setSpacing(4);
        
        // 左侧按钮组
        createLeftButtons(layout);
        
        // 标题
        m_titleLabel = new QLabel("ReactOS");
        m_titleLabel->setStyleSheet(R"(
            QLabel {
                color: #1C1B1F;
                font-size: 14px;
                font-weight: 500;
                padding: 0 16px;
            }
        )");
        layout->addWidget(m_titleLabel, 1);
        
        // 右侧按钮组
        createRightButtons(layout);
        
        // Material 3 样式
        setStyleSheet(R"(
            Material3TitleBar {
                background: qlineargradient(
                    x1:0, y1:0, x2:1, y2:0,
                    stop:0 #EADDFF,
                    stop:1 #E8DEF8
                );
                border-top-left-radius: 12px;
                border-top-right-radius: 12px;
            }
        )");
    }
    
private:
    void createLeftButtons(QHBoxLayout *layout) {
        // Material 3 图标按钮
        m_closeLeft = createIconButton("×", "#B3261E");
        m_minimizeLeft = createIconButton("─", "#49454F");
        m_maximizeLeft = createIconButton("○", "#49454F");
        
        layout->addWidget(m_closeLeft);
        layout->addWidget(m_minimizeLeft);
        layout->addWidget(m_maximizeLeft);
    }
    
    void createRightButtons(QHBoxLayout *layout) {
        m_minimizeRight = createIconButton("─", "#49454F");
        m_maximizeRight = createIconButton("○", "#49454F");
        m_closeRight = createIconButton("×", "#B3261E");
        
        layout->addWidget(m_minimizeRight);
        layout->addWidget(m_maximizeRight);
        layout->addWidget(m_closeRight);
    }
    
    QPushButton* createIconButton(const QString &icon, const QString &color) {
        QPushButton *btn = new QPushButton(icon);
        btn->setFixedSize(40, 40);
        
        btn->setStyleSheet(QString(R"(
            QPushButton {
                background-color: transparent;
                color: %1;
                border: none;
                border-radius: 20px;
                font-size: 18px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: rgba(103, 80, 164, 0.08);
            }
            QPushButton:pressed {
                background-color: rgba(103, 80, 164, 0.12);
            }
        )").arg(color));
        
        return btn;
    }
    
    QLabel *m_titleLabel;
    QPushButton *m_closeLeft, *m_minimizeLeft, *m_maximizeLeft;
    QPushButton *m_closeRight, *m_minimizeRight, *m_maximizeRight;
};
```

---

## 第四部分：按钮设计

### Material 3 按钮样式

#### 1. Filled Button（填充按钮）

```cpp
class Material3FilledButton : public QPushButton {
public:
    Material3FilledButton(const QString &text, QWidget *parent = nullptr)
        : QPushButton(text, parent) {
        
        setMinimumHeight(40);
        setStyleSheet(R"(
            QPushButton {
                background-color: #6750A4;
                color: #FFFFFF;
                border: none;
                border-radius: 20px;
                padding: 10px 24px;
                font-size: 14px;
                font-weight: 500;
                /* Material 3 强阴影 */
                box-shadow: 0px 1px 2px rgba(0, 0, 0, 0.3),
                           0px 1px 3px rgba(0, 0, 0, 0.15);
            }
            QPushButton:hover {
                background-color: #7965AF;
                box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.3),
                           0px 4px 8px rgba(0, 0, 0, 0.15);
            }
            QPushButton:pressed {
                background-color: #5A3F8F;
                box-shadow: 0px 1px 2px rgba(0, 0, 0, 0.3);
            }
        )");
    }
};
```

#### 2. Outlined Button（轮廓按钮）

```cpp
class Material3OutlinedButton : public QPushButton {
public:
    Material3OutlinedButton(const QString &text, QWidget *parent = nullptr)
        : QPushButton(text, parent) {
        
        setMinimumHeight(40);
        setStyleSheet(R"(
            QPushButton {
                background-color: transparent;
                color: #6750A4;
                border: 1px solid #79747E;
                border-radius: 20px;
                padding: 10px 24px;
                font-size: 14px;
                font-weight: 500;
            }
            QPushButton:hover {
                background-color: rgba(103, 80, 164, 0.08);
                border-color: #6750A4;
            }
            QPushButton:pressed {
                background-color: rgba(103, 80, 164, 0.12);
            }
        )");
    }
};
```

#### 3. Text Button（文本按钮）

```cpp
class Material3TextButton : public QPushButton {
public:
    Material3TextButton(const QString &text, QWidget *parent = nullptr)
        : QPushButton(text, parent) {
        
        setMinimumHeight(40);
        setStyleSheet(R"(
            QPushButton {
                background-color: transparent;
                color: #6750A4;
                border: none;
                border-radius: 20px;
                padding: 10px 12px;
                font-size: 14px;
                font-weight: 500;
            }
            QPushButton:hover {
                background-color: rgba(103, 80, 164, 0.08);
            }
            QPushButton:pressed {
                background-color: rgba(103, 80, 164, 0.12);
            }
        )");
    }
};
```

#### 4. FAB（浮动操作按钮）

```cpp
class Material3FAB : public QPushButton {
public:
    Material3FAB(const QString &icon, QWidget *parent = nullptr)
        : QPushButton(icon, parent) {
        
        setFixedSize(56, 56);
        setStyleSheet(R"(
            QPushButton {
                background-color: #6750A4;
                color: #FFFFFF;
                border: none;
                border-radius: 28px;
                font-size: 24px;
                /* Material 3 强阴影（浮动效果）*/
                box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.3),
                           0px 8px 16px rgba(0, 0, 0, 0.15);
            }
            QPushButton:hover {
                background-color: #7965AF;
                box-shadow: 0px 6px 12px rgba(0, 0, 0, 0.3),
                           0px 12px 24px rgba(0, 0, 0, 0.15);
            }
            QPushButton:pressed {
                background-color: #5A3F8F;
                box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.3);
            }
        )");
    }
};
```

---

## 第五部分：卡片和表面

### Material 3 卡片

```cpp
class Material3Card : public QFrame {
public:
    Material3Card(QWidget *parent = nullptr)
        : QFrame(parent) {
        
        setStyleSheet(R"(
            Material3Card {
                background-color: #FFFBFE;
                border: 1px solid #CAC4D0;
                border-radius: 12px;
                padding: 16px;
                /* Material 3 卡片阴影 */
                box-shadow: 0px 1px 2px rgba(0, 0, 0, 0.3),
                           0px 1px 3px rgba(0, 0, 0, 0.15);
            }
        )");
    }
};

class Material3ElevatedCard : public QFrame {
public:
    Material3ElevatedCard(QWidget *parent = nullptr)
        : QFrame(parent) {
        
        setStyleSheet(R"(
            Material3ElevatedCard {
                background-color: #FFFBFE;
                border: none;
                border-radius: 12px;
                padding: 16px;
                /* Material 3 强阴影（浮起效果）*/
                box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.3),
                           0px 4px 8px rgba(0, 0, 0, 0.15);
            }
        )");
    }
};
```

---

## 第六部分：菜单和对话框

### Material 3 菜单

```cpp
class Material3Menu : public QMenu {
public:
    Material3Menu(QWidget *parent = nullptr)
        : QMenu(parent) {
        
        setStyleSheet(R"(
            QMenu {
                background-color: #FFFBFE;
                border: 1px solid #CAC4D0;
                border-radius: 8px;
                padding: 8px 0;
                /* Material 3 菜单阴影 */
                box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.3),
                           0px 8px 16px rgba(0, 0, 0, 0.15);
            }
            QMenu::item {
                padding: 12px 24px;
                color: #1C1B1F;
            }
            QMenu::item:selected {
                background-color: rgba(103, 80, 164, 0.08);
                border-radius: 4px;
            }
            QMenu::item:pressed {
                background-color: rgba(103, 80, 164, 0.12);
            }
        )");
    }
};
```

---

## 第七部分：完整示例

### Material 3 Explorer

```cpp
class Material3Explorer : public Material3Window {
public:
    Material3Explorer() {
        setWindowTitle("文件资源管理器");
        resize(1024, 768);
        
        // 中心部件
        QWidget *central = new QWidget;
        QVBoxLayout *mainLayout = new QVBoxLayout(central);
        mainLayout->setContentsMargins(0, 0, 0, 0);
        mainLayout->setSpacing(0);
        
        // 工具栏
        createToolbar(mainLayout);
        
        // 内容区域
        QHBoxLayout *contentLayout = new QHBoxLayout;
        contentLayout->setSpacing(16);
        contentLayout->setContentsMargins(16, 16, 16, 16);
        
        // 左侧导航（Material 3 卡片）
        Material3Card *navCard = new Material3Card;
        QVBoxLayout *navLayout = new QVBoxLayout(navCard);
        
        QTreeView *treeView = new QTreeView;
        treeView->setStyleSheet(R"(
            QTreeView {
                background-color: transparent;
                border: none;
            }
            QTreeView::item:hover {
                background-color: rgba(103, 80, 164, 0.08);
                border-radius: 8px;
            }
            QTreeView::item:selected {
                background-color: rgba(103, 80, 164, 0.12);
                border-radius: 8px;
            }
        )");
        navLayout->addWidget(treeView);
        contentLayout->addWidget(navCard, 1);
        
        // 右侧文件列表（Material 3 卡片）
        Material3ElevatedCard *fileCard = new Material3ElevatedCard;
        QVBoxLayout *fileLayout = new QVBoxLayout(fileCard);
        
        QListView *listView = new QListView;
        listView->setStyleSheet(R"(
            QListView {
                background-color: transparent;
                border: none;
            }
            QListView::item {
                padding: 12px;
                border-radius: 8px;
            }
            QListView::item:hover {
                background-color: rgba(103, 80, 164, 0.08);
            }
            QListView::item:selected {
                background-color: #EADDFF;
                color: #21005D;
            }
        )");
        fileLayout->addWidget(listView);
        contentLayout->addWidget(fileCard, 3);
        
        mainLayout->addLayout(contentLayout);
        
        setCentralWidget(central);
        
        // 浮动操作按钮
        Material3FAB *fab = new Material3FAB("+", this);
        fab->move(width() - 72, height() - 72);
    }
    
private:
    void createToolbar(QVBoxLayout *layout) {
        QWidget *toolbar = new QWidget;
        toolbar->setStyleSheet(R"(
            QWidget {
                background: qlineargradient(
                    x1:0, y1:0, x2:1, y2:0,
                    stop:0 #EADDFF,
                    stop:1 #FFFBFE
                );
                padding: 8px 16px;
            }
        )");
        
        QHBoxLayout *toolLayout = new QHBoxLayout(toolbar);
        
        // 添加 Material 3 按钮
        toolLayout->addWidget(new Material3TextButton("后退"));
        toolLayout->addWidget(new Material3TextButton("前进"));
        toolLayout->addWidget(new Material3TextButton("上一级"));
        toolLayout->addStretch();
        toolLayout->addWidget(new Material3OutlinedButton("搜索"));
        
        layout->addWidget(toolbar);
    }
};
```

---

## 第八部分：Qt 样式表总结

### 完整 Material 3 QSS

```css
/* Material 3 Expressive 全局样式 */

/* 主窗口 */
QMainWindow {
    background-color: #FFFBFE;
    border-radius: 12px;
}

/* 填充按钮 */
QPushButton {
    background-color: #6750A4;
    color: #FFFFFF;
    border: none;
    border-radius: 20px;
    padding: 10px 24px;
    font-size: 14px;
    font-weight: 500;
}

QPushButton:hover {
    background-color: #7965AF;
}

QPushButton:pressed {
    background-color: #5A3F8F;
}

/* 文本框 */
QLineEdit {
    background-color: #E7E0EC;
    color: #1C1B1F;
    border: 1px solid #79747E;
    border-radius: 8px;
    padding: 12px 16px;
    font-size: 14px;
}

QLineEdit:focus {
    border: 2px solid #6750A4;
    background-color: #FFFBFE;
}

/* 列表 */
QListView {
    background-color: #FFFBFE;
    border: 1px solid #CAC4D0;
    border-radius: 12px;
}

QListView::item {
    padding: 12px;
    border-radius: 8px;
}

QListView::item:hover {
    background-color: rgba(103, 80, 164, 0.08);
}

QListView::item:selected {
    background-color: #EADDFF;
    color: #21005D;
}

/* 菜单栏 */
QMenuBar {
    background: qlineargradient(
        x1:0, y1:0, x2:1, y2:0,
        stop:0 #EADDFF,
        stop:1 #E8DEF8
    );
    padding: 4px;
}

QMenuBar::item {
    padding: 8px 16px;
    border-radius: 8px;
}

QMenuBar::item:selected {
    background-color: rgba(103, 80, 164, 0.08);
}

/* 菜单 */
QMenu {
    background-color: #FFFBFE;
    border: 1px solid #CAC4D0;
    border-radius: 8px;
    padding: 8px 0;
}

QMenu::item {
    padding: 12px 24px;
}

QMenu::item:selected {
    background-color: rgba(103, 80, 164, 0.08);
}
```

---

## 总结

### Material 3 vs 毛玻璃

| 特性 | 毛玻璃风格 | Material 3 Expressive |
|------|-----------|---------------------|
| **背景** | 半透明模糊 | 纯色 + 渐变 |
| **深度** | 模糊层次 | 强阴影 |
| **色彩** | 柔和 | 大胆鲜明 |
| **性能** | 中等（需要模糊） | 高（无模糊计算）|
| **风格** | Windows 11 | Google Material 3 |

### 实施建议

1. **移除毛玻璃代码**：
   - 删除 `DwmEnableBlurBehindWindow`
   - 删除 `WA_TranslucentBackground`

2. **应用 Material 3 样式**：
   - 使用纯色背景
   - 添加强阴影
   - 使用色彩渐变

3. **更新组件**：
   - 按钮 → Material 3 按钮
   - 卡片 → Material 3 卡片
   - 菜单 → Material 3 菜单

---

**文档版本**：1.0  
**最后更新**：2025-10-26  
**风格**：Google Material 3 Expressive（无毛玻璃）
