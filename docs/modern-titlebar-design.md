# 现代化标题栏设计方案

## 设计目标

创建一个基于 **Material 3 Expressive** 风格的现代化标题栏，支持**双侧按钮布局**：
- **左侧**：窗口控制按钮（最小化、最大化、关闭）
- **中间**：应用图标 + 标题
- **右侧**：窗口控制按钮（最小化、最大化、关闭）

## 视觉效果

```
╭─────────────────────────────────────────╮
│ × ─ ○ │    ◯ ReactOS         │ ─ ○ × │  ← Material 3 纯色背景 + 强阴影
├─────────────────────────────────────────┤
│ 文件  编辑  查看  帮助                  │  ← 纯色菜单栏 + 色彩渐变
├─────────────────────────────────────────┤
│                                         │
│  ╭───────╮  ╭───────╮  ╭───────╮      │  ← 浮动按钮 + 强阴影
│  │ 按钮1 │  │ 按钮2 │  │ 按钮3 │      │  ← 圆角设计
│  ╰───────╯  ╰───────╯  ╰───────╯      │
│                                         │
│  [色彩渐变背景]                         │  ← 渐变而非毛玻璃
│                                         │
╰─────────────────────────────────────────╯

说明：
- 左侧：× ─ ○ (关闭、最小化、最大化) - macOS 风格顺序
- 中间：◯ ReactOS (应用图标 + 标题)
- 右侧：─ ○ × (最小化、最大化、关闭) - Windows 风格顺序
- **Material 3 Expressive 风格**：纯色背景 + 强阴影 + 色彩渐变
```

## 设计理念

### 为什么双侧按钮？

#### 1. 用户选择自由
- **左手用户**：使用左侧按钮
- **右手用户**：使用右侧按钮
- **触摸屏**：两侧都可以点击

#### 2. 平台兼容性
- **macOS 风格**：左侧按钮（红黄绿）
- **Windows 风格**：右侧按钮
- **Linux 风格**：可配置

#### 3. 现代化趋势
- 提供更多选择
- 适应不同使用习惯
- 无障碍设计

## 技术实现

### 1. 标题栏布局

```cpp
class ModernTitleBar : public CWnd {
private:
    static const int BUTTON_WIDTH = 46;
    static const int BUTTON_HEIGHT = 32;
    static const int ICON_SIZE = 20;
    static const int TITLE_MARGIN = 8;
    
    // 按钮
    CButton m_btnMinimizeLeft;
    CButton m_btnMaximizeLeft;
    CButton m_btnCloseLeft;
    
    CButton m_btnMinimizeRight;
    CButton m_btnMaximizeRight;
    CButton m_btnCloseRight;
    
    // 标题
    CString m_strTitle;
    HICON m_hIcon;
    
public:
    void LayoutControls() {
        CRect rect;
        GetClientRect(&rect);
        
        int y = (rect.Height() - BUTTON_HEIGHT) / 2;
        
        // 左侧按钮组 (macOS 风格: 关闭、最小化、最大化)
        int leftX = 0;
        m_btnCloseLeft.SetWindowPos(NULL, 
            leftX, y, BUTTON_WIDTH, BUTTON_HEIGHT, 
            SWP_NOZORDER);
        leftX += BUTTON_WIDTH;
        
        m_btnMinimizeLeft.SetWindowPos(NULL, 
            leftX, y, BUTTON_WIDTH, BUTTON_HEIGHT, 
            SWP_NOZORDER);
        leftX += BUTTON_WIDTH;
        
        m_btnMaximizeLeft.SetWindowPos(NULL, 
            leftX, y, BUTTON_WIDTH, BUTTON_HEIGHT, 
            SWP_NOZORDER);
        leftX += BUTTON_WIDTH;
        
        // 右侧按钮组 (Windows 风格: 最小化、最大化、关闭)
        int rightX = rect.Width() - BUTTON_WIDTH * 3;
        m_btnMinimizeRight.SetWindowPos(NULL, 
            rightX, y, BUTTON_WIDTH, BUTTON_HEIGHT, 
            SWP_NOZORDER);
        rightX += BUTTON_WIDTH;
        
        m_btnMaximizeRight.SetWindowPos(NULL, 
            rightX, y, BUTTON_WIDTH, BUTTON_HEIGHT, 
            SWP_NOZORDER);
        rightX += BUTTON_WIDTH;
        
        m_btnCloseRight.SetWindowPos(NULL, 
            rightX, y, BUTTON_WIDTH, BUTTON_HEIGHT, 
            SWP_NOZORDER);
        
        // 中间区域留给标题和图标
        m_titleRect = CRect(
            leftX + TITLE_MARGIN,
            0,
            rightX - TITLE_MARGIN,
            rect.Height()
        );
    }
    
    void OnPaint() {
        CPaintDC dc(this);
        
        if (!m_pRenderTarget) {
            CreateRenderTarget();
        }
        
        m_pRenderTarget->BeginDraw();
        
        // 绘制背景（Material 3 纯色背景 + 强阴影）
        DrawMaterial3Background();
        
        // 绘制标题和图标
        DrawTitleAndIcon();
        
        m_pRenderTarget->EndDraw();
    }
    
    void DrawMaterial3Background() {
        CRect rect;
        GetClientRect(&rect);
        
        // Material 3 表面色 (#FFFBFE)
        ID2D1SolidColorBrush* bgBrush;
        m_pRenderTarget->CreateSolidColorBrush(
            D2D1::ColorF(0xFFFBFE),  // Material 3 表面色
            &bgBrush
        );
        
        // 绘制圆角矩形背景
        D2D1_ROUNDED_RECT roundedRect = D2D1::RoundedRect(
            D2D1::RectF(0, 0, rect.Width(), rect.Height()),
            8.0f, 8.0f
        );
        
        m_pRenderTarget->FillRoundedRectangle(roundedRect, bgBrush);
        
        // 绘制 Material 3 强阴影
        DrawMaterial3Shadow(roundedRect);
        
        bgBrush->Release();
    }
    
    void DrawMaterial3Shadow(const D2D1_ROUNDED_RECT& rect) {
        // Material 3 强阴影效果
        ID2D1Effect* shadowEffect;
        m_pRenderTarget->CreateEffect(CLSID_D2D1Shadow, &shadowEffect);
        
        shadowEffect->SetValue(
            D2D1_SHADOW_PROP_BLUR_STANDARD_DEVIATION, 
            4.0f  // 更强的阴影
        );
        shadowEffect->SetValue(
            D2D1_SHADOW_PROP_COLOR, 
            D2D1::Vector4F(0, 0, 0, 0.12f)  // Material 3 阴影颜色
        );
        
        // 应用阴影到背景
        m_pRenderTarget->DrawImage(shadowEffect);
        shadowEffect->Release();
    }
    
    void DrawTitleAndIcon() {
        // 计算中心位置
        int centerX = m_titleRect.CenterPoint().x;
        int centerY = m_titleRect.CenterPoint().y;
        
        // 绘制图标
        if (m_hIcon) {
            int iconX = centerX - (ICON_SIZE + m_strTitle.GetLength() * 4);
            int iconY = centerY - ICON_SIZE / 2;
            
            DrawIconEx(
                m_pRenderTarget->GetDC(),
                iconX, iconY,
                m_hIcon,
                ICON_SIZE, ICON_SIZE,
                0, NULL, DI_NORMAL
            );
        }
        
        // 绘制标题文本
        IDWriteTextFormat* textFormat;
        m_pDWriteFactory->CreateTextFormat(
            L"Segoe UI",
            NULL,
            DWRITE_FONT_WEIGHT_NORMAL,
            DWRITE_FONT_STYLE_NORMAL,
            DWRITE_FONT_STRETCH_NORMAL,
            12.0f,
            L"",
            &textFormat
        );
        
        textFormat->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_CENTER);
        textFormat->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
        
        ID2D1SolidColorBrush* brush;
        m_pRenderTarget->CreateSolidColorBrush(
            D2D1::ColorF(D2D1::ColorF::White),
            &brush
        );
        
        m_pRenderTarget->DrawText(
            m_strTitle,
            m_strTitle.GetLength(),
            textFormat,
            D2D1::RectF(
                m_titleRect.left,
                m_titleRect.top,
                m_titleRect.right,
                m_titleRect.bottom
            ),
            brush
        );
        
        brush->Release();
        textFormat->Release();
    }
};
```

### 2. 现代化按钮

```cpp
class ModernTitleBarButton : public CButton {
private:
    enum ButtonType {
        BTN_MINIMIZE,
        BTN_MAXIMIZE,
        BTN_CLOSE
    };
    
    ButtonType m_type;
    bool m_isHovered;
    bool m_isPressed;
    
public:
    void SetButtonType(ButtonType type) {
        m_type = type;
    }
    
    void OnPaint() {
        CPaintDC dc(this);
        
        if (!m_pRenderTarget) {
            CreateRenderTarget();
        }
        
        m_pRenderTarget->BeginDraw();
        
        CRect rect;
        GetClientRect(&rect);
        
        // Material 3 按钮背景色
        D2D1_COLOR_F bgColor;
        if (m_type == BTN_CLOSE) {
            // Material 3 关闭按钮颜色
            if (m_isPressed) {
                bgColor = D2D1::ColorF(0x410E0B);  // Material 3 错误容器深色
            } else if (m_isHovered) {
                bgColor = D2D1::ColorF(0xB3261E);  // Material 3 错误色
            } else {
                bgColor = D2D1::ColorF(0x000000, 0);  // 透明
            }
        } else {
            // Material 3 最小化和最大化按钮颜色
            if (m_isPressed) {
                bgColor = D2D1::ColorF(0x4F378B);  // Material 3 主容器深色
            } else if (m_isHovered) {
                bgColor = D2D1::ColorF(0x6750A4);  // Material 3 主色
            } else {
                bgColor = D2D1::ColorF(0x000000, 0);  // 透明
            }
        }
        
        // 绘制背景
        ID2D1SolidColorBrush* bgBrush;
        m_pRenderTarget->CreateSolidColorBrush(bgColor, &bgBrush);
        m_pRenderTarget->FillRectangle(
            D2D1::RectF(0, 0, rect.Width(), rect.Height()),
            bgBrush
        );
        bgBrush->Release();
        
        // 绘制图标
        DrawIcon();
        
        m_pRenderTarget->EndDraw();
    }
    
    void DrawIcon() {
        CRect rect;
        GetClientRect(&rect);
        
        ID2D1SolidColorBrush* iconBrush;
        D2D1_COLOR_F iconColor = (m_isHovered || m_isPressed) 
            ? D2D1::ColorF(D2D1::ColorF::White)
            : D2D1::ColorF(0xFFFFFF, 0.8f);
        
        m_pRenderTarget->CreateSolidColorBrush(iconColor, &iconBrush);
        
        float centerX = rect.Width() / 2.0f;
        float centerY = rect.Height() / 2.0f;
        float size = 10.0f;
        
        switch (m_type) {
        case BTN_MINIMIZE:
            // 绘制横线 (─)
            m_pRenderTarget->DrawLine(
                D2D1::Point2F(centerX - size/2, centerY),
                D2D1::Point2F(centerX + size/2, centerY),
                iconBrush,
                1.0f
            );
            break;
            
        case BTN_MAXIMIZE:
            // 绘制方框 (○)
            m_pRenderTarget->DrawRectangle(
                D2D1::RectF(
                    centerX - size/2,
                    centerY - size/2,
                    centerX + size/2,
                    centerY + size/2
                ),
                iconBrush,
                1.0f
            );
            break;
            
        case BTN_CLOSE:
            // 绘制 X
            m_pRenderTarget->DrawLine(
                D2D1::Point2F(centerX - size/2, centerY - size/2),
                D2D1::Point2F(centerX + size/2, centerY + size/2),
                iconBrush,
                1.0f
            );
            m_pRenderTarget->DrawLine(
                D2D1::Point2F(centerX + size/2, centerY - size/2),
                D2D1::Point2F(centerX - size/2, centerY + size/2),
                iconBrush,
                1.0f
            );
            break;
        }
        
        iconBrush->Release();
    }
    
    void OnMouseMove(UINT nFlags, CPoint point) {
        if (!m_isHovered) {
            m_isHovered = true;
            Invalidate();
            
            // 启动跟踪鼠标离开
            TRACKMOUSEEVENT tme;
            tme.cbSize = sizeof(tme);
            tme.dwFlags = TME_LEAVE;
            tme.hwndTrack = m_hWnd;
            TrackMouseEvent(&tme);
        }
    }
    
    void OnMouseLeave() {
        m_isHovered = false;
        Invalidate();
    }
};
```

### 3. 用户配置

```cpp
class TitleBarConfig {
public:
    enum ButtonPosition {
        LEFT_ONLY,      // 仅左侧
        RIGHT_ONLY,     // 仅右侧（Windows 默认）
        BOTH_SIDES,     // 双侧（推荐）
        CENTER          // 居中
    };
    
    static ButtonPosition GetButtonPosition() {
        // 从注册表读取用户配置
        DWORD value = 0;
        RegGetValue(
            HKEY_CURRENT_USER,
            L"Software\\ReactOS\\Desktop",
            L"TitleBarButtonPosition",
            RRF_RT_DWORD,
            NULL,
            &value,
            NULL
        );
        
        return (ButtonPosition)value;
    }
    
    static void SetButtonPosition(ButtonPosition pos) {
        DWORD value = (DWORD)pos;
        RegSetValueEx(
            HKEY_CURRENT_USER,
            L"Software\\ReactOS\\Desktop",
            0,
            REG_DWORD,
            (BYTE*)&value,
            sizeof(value)
        );
    }
};
```

## 设计变体

### 变体 1：Windows 风格（默认）
```
╭─────────────────────────────────────────╮
│    ◯ ReactOS                  │ ─ ○ × │
├─────────────────────────────────────────┤
```
- 仅右侧按钮
- 标题居左

### 变体 2：macOS 风格
```
╭─────────────────────────────────────────╮
│ ● ● ● │         ReactOS                │
├─────────────────────────────────────────┤
```
- 仅左侧按钮（红黄绿）
- 标题居中

### 变体 3：双侧风格（推荐）
```
╭─────────────────────────────────────────╮
│ × ─ ○ │    ◯ ReactOS         │ ─ ○ × │
├─────────────────────────────────────────┤
```
- 左侧：× ─ ○ (macOS 风格顺序)
- 右侧：─ ○ × (Windows 风格顺序)
- 标题居中

### 变体 4：极简风格
```
╭─────────────────────────────────────────╮
│         ◯ ReactOS         ─ ○ ×        │
├─────────────────────────────────────────┤
```
- 按钮居中右侧
- 标题居中左侧

## 完整窗口示例

```cpp
class ModernWindow : public CFrameWnd {
private:
    ModernTitleBar m_titleBar;
    
protected:
    int OnCreate(LPCREATESTRUCT lpCreateStruct) {
        if (CFrameWnd::OnCreate(lpCreateStruct) == -1)
            return -1;
        
        // 创建自定义标题栏
        m_titleBar.Create(
            NULL,
            NULL,
            WS_CHILD | WS_VISIBLE,
            CRect(0, 0, 0, 32),
            this,
            1
        );
        
        // 设置圆角窗口
        DWM_WINDOW_CORNER_PREFERENCE preference = DWMWCP_ROUND;
        DwmSetWindowAttribute(
            m_hWnd,
            DWMWA_WINDOW_CORNER_PREFERENCE,
            &preference,
            sizeof(preference)
        );
        
        // 启用毛玻璃
        EnableBlur();
        
        return 0;
    }
    
    void OnSize(UINT nType, int cx, int cy) {
        CFrameWnd::OnSize(nType, cx, cy);
        
        // 调整标题栏大小
        if (m_titleBar.m_hWnd) {
            m_titleBar.SetWindowPos(
                NULL,
                0, 0, cx, 32,
                SWP_NOZORDER
            );
        }
    }
};
```

## 实施建议

### 阶段 1：基础实现（2 周）
1. 创建 ModernTitleBar 类
2. 实现基本布局
3. 添加按钮

### 阶段 2：视觉效果（2 周）
1. Direct2D 渲染
2. 毛玻璃背景
3. 悬停动画

### 阶段 3：用户配置（1 周）
1. 配置界面
2. 注册表存储
3. 实时切换

### 阶段 4：系统集成（1 周）
1. 集成到 Explorer
2. 集成到所有系统窗口
3. 主题支持

## 用户体验优势

### 1. 无障碍
- 左右手都方便
- 触摸屏友好
- 大目标区域

### 2. 灵活性
- 用户可选择
- 适应不同习惯
- 跨平台一致性

### 3. 现代化
- Windows 11 风格
- 流畅动画
- 精致细节

---

**文档版本**：1.0  
**最后更新**：2025-10-26  
**推荐配置**：双侧按钮布局
