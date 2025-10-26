# ReactOS Material 3 Expressive UI 实现指南

## 概述

本指南详细说明如何在 ReactOS 中实现 **Material 3 Expressive** 风格的现代化界面。

## 目标效果

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
- 左侧：× ─ ○ (关闭、最小化、最大化) - macOS 风格
- 中间：◯ ReactOS (应用图标 + 标题)
- 右侧：─ ○ × (最小化、最大化、关闭) - Windows 风格
- **Material 3 Expressive 风格**：纯色背景 + 强阴影 + 色彩渐变
```

## 实现技术

### 1. 圆角窗口

**使用 DWM API**：
```cpp
// 设置圆角窗口
DWM_WINDOW_CORNER_PREFERENCE preference = DWMWCP_ROUND;
DwmSetWindowAttribute(
    hwnd,
    DWMWA_WINDOW_CORNER_PREFERENCE,
    &preference,
    sizeof(preference)
);
```

**使用 Direct2D**：
```cpp
// 绘制圆角矩形
D2D1_ROUNDED_RECT roundedRect = D2D1::RoundedRect(
    D2D1::RectF(0, 0, width, height),
    8.0f,  // X 轴圆角半径
    8.0f   // Y 轴圆角半径
);

renderTarget->FillRoundedRectangle(roundedRect, brush);
```

### 2. Material 3 表面效果

**Material 3 纯色背景**（替代毛玻璃效果）：
```cpp
// Material 3 表面色 (#FFFBFE)
ID2D1SolidColorBrush* surfaceBrush;
renderTarget->CreateSolidColorBrush(
    D2D1::ColorF(0xFFFBFE),  // Material 3 表面色
    &surfaceBrush
);

// 绘制圆角矩形背景
D2D1_ROUNDED_RECT roundedRect = D2D1::RoundedRect(
    D2D1::RectF(0, 0, width, height),
    8.0f, 8.0f
);

renderTarget->FillRoundedRectangle(roundedRect, surfaceBrush);
```

**Material 3 色彩渐变**：
```cpp
// 创建线性渐变画笔
ID2D1LinearGradientBrush* gradientBrush;
ID2D1GradientStopCollection* gradientStops;

D2D1_GRADIENT_STOP stops[] = {
    {0.0f, D2D1::ColorF(0x6750A4)},  // Material 3 主色
    {1.0f, D2D1::ColorF(0x4F378B)}   // Material 3 主容器色
};

renderTarget->CreateGradientStopCollection(
    stops, 2, D2D1_GAMMA_2_2, D2D1_EXTEND_MODE_CLAMP,
    &gradientStops
);

renderTarget->CreateLinearGradientBrush(
    D2D1::LinearGradientBrushProperties(
        D2D1::Point2F(0, 0),
        D2D1::Point2F(width, height)
    ),
    gradientStops,
    &gradientBrush
);
```

### 3. 阴影效果

**使用 Direct2D Shadow Effect**：
```cpp
ID2D1Effect* shadowEffect;
renderTarget->CreateEffect(CLSID_D2D1Shadow, &shadowEffect);

shadowEffect->SetInput(0, bitmap);
shadowEffect->SetValue(D2D1_SHADOW_PROP_BLUR_STANDARD_DEVIATION, 3.0f);
shadowEffect->SetValue(D2D1_SHADOW_PROP_COLOR, 
    D2D1::Vector4F(0, 0, 0, 0.3f));

renderTarget->DrawImage(shadowEffect);
```

### 4. 现代图标

**使用 Segoe Fluent Icons 字体**：
```cpp
HFONT hFont = CreateFont(
    20, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
    DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
    CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY,
    DEFAULT_PITCH | FF_DONTCARE,
    L"Segoe Fluent Icons"
);

// 图标 Unicode
// ◯ = \uE91B (应用图标)
// ─ = \uE921 (最小化)
// ○ = \uE923 (最大化)
// × = \uE8BB (关闭)
```

### 5. 流畅动画

**使用 Windows Animation Manager**：
```cpp
IUIAnimationManager* animationManager;
IUIAnimationVariable* opacityVariable;

// 淡入动画
IUIAnimationTransition* transition;
transitionLibrary->CreateAccelerateDecelerateTransition(
    0.3,  // 300ms
    1.0,  // 目标值
    0.5, 0.5,
    &transition
);

storyboard->AddTransition(opacityVariable, transition);
storyboard->Schedule(GetCurrentTime());
```

## 完整示例

### 现代化按钮类

```cpp
class ModernButton : public CButton {
private:
    ID2D1HwndRenderTarget* m_pRenderTarget;
    ID2D1SolidColorBrush* m_pBrush;
    bool m_isHovered;
    bool m_isPressed;

public:
    void OnPaint() {
        CPaintDC dc(this);
        
        if (!m_pRenderTarget) {
            CreateRenderTarget();
        }
        
        m_pRenderTarget->BeginDraw();
        m_pRenderTarget->Clear(D2D1::ColorF(D2D1::ColorF::White, 0));
        
        // 获取按钮矩形
        CRect rect;
        GetClientRect(&rect);
        
        // 圆角矩形
        D2D1_ROUNDED_RECT roundedRect = D2D1::RoundedRect(
            D2D1::RectF(0, 0, rect.Width(), rect.Height()),
            8.0f, 8.0f
        );
        
        // 根据状态选择颜色
        D2D1_COLOR_F color;
        if (m_isPressed) {
            color = D2D1::ColorF(0x005A9E);  // 按下色
        } else if (m_isHovered) {
            color = D2D1::ColorF(0x0078D4);  // 悬停色
        } else {
            color = D2D1::ColorF(0x0063B1);  // 正常色
        }
        
        m_pBrush->SetColor(color);
        
        // 绘制阴影
        DrawShadow(roundedRect);
        
        // 绘制按钮背景
        m_pRenderTarget->FillRoundedRectangle(roundedRect, m_pBrush);
        
        // 绘制文本
        DrawText(rect);
        
        m_pRenderTarget->EndDraw();
    }
    
    void DrawShadow(const D2D1_ROUNDED_RECT& rect) {
        // 创建阴影效果
        ID2D1Effect* shadowEffect;
        m_pRenderTarget->CreateEffect(CLSID_D2D1Shadow, &shadowEffect);
        
        shadowEffect->SetValue(
            D2D1_SHADOW_PROP_BLUR_STANDARD_DEVIATION, 
            3.0f
        );
        shadowEffect->SetValue(
            D2D1_SHADOW_PROP_COLOR, 
            D2D1::Vector4F(0, 0, 0, 0.3f)
        );
        
        m_pRenderTarget->DrawImage(shadowEffect);
        shadowEffect->Release();
    }
    
    void OnMouseMove(UINT nFlags, CPoint point) {
        if (!m_isHovered) {
            m_isHovered = true;
            Invalidate();
            
            // 启动悬停动画
            StartHoverAnimation();
        }
    }
    
    void OnMouseLeave() {
        m_isHovered = false;
        Invalidate();
    }
};
```

### 现代化窗口类

```cpp
class ModernWindow : public CFrameWnd {
protected:
    void OnCreate() {
        // 设置圆角窗口
        DWM_WINDOW_CORNER_PREFERENCE preference = DWMWCP_ROUND;
        DwmSetWindowAttribute(
            m_hWnd,
            DWMWA_WINDOW_CORNER_PREFERENCE,
            &preference,
            sizeof(preference)
        );
        
        // 启用毛玻璃效果
        EnableBlur();
        
        // 设置深色模式
        BOOL darkMode = TRUE;
        DwmSetWindowAttribute(
            m_hWnd,
            DWMWA_USE_IMMERSIVE_DARK_MODE,
            &darkMode,
            sizeof(darkMode)
        );
    }
    
    void EnableBlur() {
        DWM_BLURBEHIND bb = {0};
        bb.dwFlags = DWM_BB_ENABLE | DWM_BB_BLURREGION;
        bb.fEnable = TRUE;
        bb.hRgnBlur = CreateRectRgn(0, 0, -1, -1);
        
        DwmEnableBlurBehindWindow(m_hWnd, &bb);
    }
};
```

## 实施步骤

### 阶段 1：基础设施（1 个月）
1. 集成 Direct2D/DirectWrite
2. 实现基本的圆角渲染
3. 测试性能

### 阶段 2：核心组件（2 个月）
1. 现代化按钮
2. 现代化文本框
3. 现代化列表
4. 现代化菜单

### 阶段 3：窗口管理（1 个月）
1. 圆角窗口
2. 毛玻璃效果
3. 阴影效果

### 阶段 4：动画系统（1 个月）
1. 淡入淡出
2. 滑动动画
3. 缩放动画

### 阶段 5：系统集成（1 个月）
1. Explorer 现代化
2. 任务栏现代化
3. 开始菜单现代化

## 性能优化

### GPU 加速
- 使用 Direct2D 硬件加速
- 缓存渲染结果
- 批量绘制

### 内存管理
- 释放未使用的资源
- 使用对象池
- 延迟加载

## 兼容性

### Windows 7/8/10/11
- 检测 DWM 可用性
- 降级到 GDI（如果需要）
- 保持功能一致性

---

**文档版本**：1.0  
**最后更新**：2025-10-26
