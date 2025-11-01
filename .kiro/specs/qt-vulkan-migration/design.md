# Design Document

## Overview

This document describes the architectural design for migrating ReactOS from Win32 + GDI to Qt + Vulkan. The design follows a gradual migration strategy where Qt-based components coexist with legacy Win32 components, allowing for incremental modernization without breaking existing functionality.

### Design Goals

- Provide modern UI with Fluent Design aesthetics
- Enable high-performance 3D graphics through Vulkan
- Maintain full backward compatibility with Win32 applications
- Minimize performance overhead
- Support incremental migration path

### Design Principles

- **Coexistence**: Qt and Win32 subsystems run side-by-side
- **Modularity**: Each component can be migrated independently
- **Performance**: Native performance with minimal framework overhead
- **Compatibility**: Existing Win32 APIs remain functional
- **Extensibility**: Easy to add new Qt-based components

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     ReactOS System                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────┐    ┌──────────────────────┐     │
│  │   Qt Subsystem       │    │  Win32 Subsystem     │     │
│  │  (Modern Apps)       │    │  (Legacy Apps)       │     │
│  ├──────────────────────┤    ├──────────────────────┤     │
│  │ - Qt Explorer        │    │ - Win32 Apps         │     │
│  │ - Qt Taskbar         │    │ - Legacy Tools       │     │
│  │ - Qt Control Panel   │    │ - Old System Apps    │     │
│  │ - Qt Settings        │    │                      │     │
│  │ - Qt Applications    │    │                      │     │
│  └──────────────────────┘    └──────────────────────┘     │
│           │                            │                   │
│           ▼                            ▼                   │
│  ┌──────────────────────────────────────────────┐         │
│  │         Qt Framework Layer                   │         │
│  │  ┌────────────┐  ┌────────────┐             │         │
│  │  │ Qt Core    │  │ Qt Widgets │             │         │
│  │  └────────────┘  └────────────┘             │         │
│  │  ┌────────────┐  ┌────────────┐             │         │
│  │  │ Qt GUI     │  │ Qt Quick   │             │         │
│  │  └────────────┘  └────────────┘             │         │
│  └──────────────────────────────────────────────┘         │
│           │                                                │
│           ▼                                                │
│  ┌──────────────────────────────────────────────┐         │
│  │         Graphics Layer                       │         │
│  │  ┌────────────┐  ┌────────────┐             │         │
│  │  │  Vulkan    │  │    GDI     │             │         │
│  │  │  Renderer  │  │  (Legacy)  │             │         │
│  │  └────────────┘  └────────────┘             │         │
│  └──────────────────────────────────────────────┘         │
│           │                            │                   │
│           ▼                            ▼                   │
│  ┌──────────────────────────────────────────────┐         │
│  │         Kernel & Drivers                     │         │
│  └──────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### Component Architecture

#### Qt Application Framework

```
ReactOSApplication (QApplication)
    │
    ├── VulkanInstance (QVulkanInstance)
    │   └── Validation Layers (Debug)
    │
    ├── ThemeManager
    │   ├── FluentTheme (Default)
    │   ├── DarkTheme
    │   └── CustomThemes
    │
    └── WindowManager
        ├── ModernWindow (Base Class)
        │   ├── CustomTitleBar
        │   ├── FramelessWindow
        │   └── ModernEffects
        │
        └── VulkanWindow (3D Rendering)
            └── VulkanRenderer
```

## Components and Interfaces

### 1. ReactOS Application Framework

**Purpose**: Provide base application infrastructure for Qt-based ReactOS applications.

**Key Classes**:

```cpp
// ReactOSApplication.h
class ReactOSApplication : public QApplication {
    Q_OBJECT
    
public:
    ReactOSApplication(int &argc, char **argv);
    ~ReactOSApplication();
    
    QVulkanInstance* vulkanInstance() const;
    ThemeManager* themeManager() const;
    WindowManager* windowManager() const;
    
    bool initializeVulkan();
    void applyTheme(const QString &themeName);
    
private:
    QVulkanInstance *m_vulkanInstance;
    ThemeManager *m_themeManager;
    WindowManager *m_windowManager;
};
```

**Responsibilities**:
- Initialize Qt environment
- Create and manage Vulkan instance
- Load and apply themes
- Manage application-wide resources

### 2. Modern Window System

**Purpose**: Provide modern window with custom title bar and effects.

**Key Classes**:

```cpp
// ModernWindow.h
class ModernWindow : public QMainWindow {
    Q_OBJECT
    
public:
    explicit ModernWindow(QWidget *parent = nullptr);
    
    void setCustomTitleBar(ModernTitleBar *titleBar);
    void enableModernEffects(bool enable);
    void setRoundedCorners(bool enable);
    void setMicaEffect(bool enable);
    
protected:
    void paintEvent(QPaintEvent *event) override;
    bool nativeEvent(const QByteArray &eventType, 
                     void *message, 
                     qintptr *result) override;
    
private:
    ModernTitleBar *m_titleBar;
    bool m_modernEffectsEnabled;
    
    void setupFramelessWindow();
    void applyWindowEffects();
};

// ModernTitleBar.h
class ModernTitleBar : public QWidget {
    Q_OBJECT
    
public:
    explicit ModernTitleBar(QWidget *parent = nullptr);
    
    void setTitle(const QString &title);
    void setIcon(const QIcon &icon);
    
signals:
    void minimizeClicked();
    void maximizeClicked();
    void closeClicked();
    
private:
    QLabel *m_iconLabel;
    QLabel *m_titleLabel;
    QPushButton *m_minimizeButton;
    QPushButton *m_maximizeButton;
    QPushButton *m_closeButton;
};
```

### 3. Vulkan Rendering System

**Purpose**: Provide high-performance 3D rendering capabilities.

**Key Classes**:

```cpp
// VulkanWindow.h
class VulkanWindow : public QVulkanWindow {
    Q_OBJECT
    
public:
    explicit VulkanWindow(QWindow *parent = nullptr);
    
    QVulkanWindowRenderer* createRenderer() override;
    
private:
    VulkanRenderer *m_renderer;
};

// VulkanRenderer.h
class VulkanRenderer : public QVulkanWindowRenderer {
public:
    explicit VulkanRenderer(VulkanWindow *window);
    
    void initResources() override;
    void initSwapChainResources() override;
    void releaseSwapChainResources() override;
    void releaseResources() override;
    
    void startNextFrame() override;
    
private:
    VulkanWindow *m_window;
    VkDevice m_device;
    VkRenderPass m_renderPass;
    VkPipeline m_pipeline;
    VkPipelineLayout m_pipelineLayout;
    
    void createRenderPass();
    void createPipeline();
    void createVertexBuffer();
    void recordCommandBuffer(VkCommandBuffer cmdBuffer);
};
```

### 4. File Explorer (QtExplorer)

**Purpose**: Modern file management interface.

**Architecture**:

```
QtExplorer (ModernWindow)
    │
    ├── NavigationPane (QTreeView)
    │   └── FileSystemModel
    │
    ├── ContentPane (QListView/QTableView)
    │   └── FileSystemModel
    │
    ├── AddressBar (QLineEdit)
    │
    ├── ToolBar (QToolBar)
    │   ├── BackButton
    │   ├── ForwardButton
    │   ├── UpButton
    │   └── SearchBox
    │
    └── StatusBar (QStatusBar)
```

**Key Classes**:

```cpp
// QtExplorer.h
class QtExplorer : public ModernWindow {
    Q_OBJECT
    
public:
    QtExplorer();
    
    void navigateTo(const QString &path);
    void goBack();
    void goForward();
    void goUp();
    
private slots:
    void onItemDoubleClicked(const QModelIndex &index);
    void onContextMenuRequested(const QPoint &pos);
    
private:
    QTreeView *m_navigationPane;
    QListView *m_contentPane;
    QFileSystemModel *m_fileSystemModel;
    QLineEdit *m_addressBar;
    QToolBar *m_toolBar;
    
    QStack<QString> m_backHistory;
    QStack<QString> m_forwardHistory;
    
    void setupUI();
    void createToolBar();
    void createContextMenu();
};
```

### 5. Taskbar (QtTaskbar)

**Purpose**: Application launcher and task switcher.

**Architecture**:

```
QtTaskbar (QWidget)
    │
    ├── StartButton (QPushButton)
    │   └── StartMenu (QMenu)
    │
    ├── TaskButtonArea (QWidget)
    │   └── TaskButtons (List<TaskButton>)
    │
    ├── SystemTray (QWidget)
    │   └── TrayIcons (List<QSystemTrayIcon>)
    │
    └── Clock (QLabel)
        └── Calendar (QCalendarWidget)
```

**Key Classes**:

```cpp
// QtTaskbar.h
class QtTaskbar : public QWidget {
    Q_OBJECT
    
public:
    QtTaskbar();
    
    void addTaskButton(const QString &title, const QIcon &icon, WId windowId);
    void removeTaskButton(WId windowId);
    void updateTaskButton(WId windowId, const QString &title);
    
private slots:
    void onStartButtonClicked();
    void onTaskButtonClicked();
    void onClockClicked();
    
private:
    QPushButton *m_startButton;
    QWidget *m_taskButtonArea;
    QHBoxLayout *m_taskButtonLayout;
    QWidget *m_systemTray;
    QLabel *m_clock;
    QTimer *m_clockTimer;
    
    QMap<WId, TaskButton*> m_taskButtons;
    
    void setupUI();
    void updateClock();
    void showStartMenu();
};

// TaskButton.h
class TaskButton : public QPushButton {
    Q_OBJECT
    
public:
    TaskButton(const QString &title, const QIcon &icon, WId windowId);
    
    WId windowId() const { return m_windowId; }
    
private:
    WId m_windowId;
};
```

### 6. Theme System

**Purpose**: Manage application appearance and styling.

**Key Classes**:

```cpp
// ThemeManager.h
class ThemeManager : public QObject {
    Q_OBJECT
    
public:
    explicit ThemeManager(QObject *parent = nullptr);
    
    void loadTheme(const QString &themeName);
    void applyTheme(QApplication *app);
    
    QString currentTheme() const;
    QStringList availableThemes() const;
    
    void setAccentColor(const QColor &color);
    void setDarkMode(bool enabled);
    
signals:
    void themeChanged(const QString &themeName);
    
private:
    QString m_currentTheme;
    QColor m_accentColor;
    bool m_darkMode;
    
    QString loadStyleSheet(const QString &themeName);
    void applyAccentColor(QString &styleSheet);
};
```

**Theme File Format** (QSS):

```css
/* fluent-light.qss */
QMainWindow {
    background-color: #F3F3F3;
}

QPushButton {
    background-color: #0078D4;
    color: white;
    border-radius: 4px;
    padding: 8px 16px;
    border: none;
}

QPushButton:hover {
    background-color: #106EBE;
}

QPushButton:pressed {
    background-color: #005A9E;
}

QMenuBar {
    background-color: rgba(243, 243, 243, 0.8);
    backdrop-filter: blur(20px);
}
```

## Data Models

### File System Model

```cpp
// Enhanced QFileSystemModel with custom columns
class ReactOSFileSystemModel : public QFileSystemModel {
    Q_OBJECT
    
public:
    enum CustomRoles {
        FileTypeRole = Qt::UserRole + 1,
        FilePermissionsRole,
        FileOwnerRole
    };
    
    QVariant data(const QModelIndex &index, int role) const override;
    int columnCount(const QModelIndex &parent) const override;
    QVariant headerData(int section, Qt::Orientation orientation, 
                       int role) const override;
};
```

### Window Model

```cpp
// Model for tracking open windows
class WindowModel : public QAbstractListModel {
    Q_OBJECT
    
public:
    struct WindowInfo {
        WId windowId;
        QString title;
        QIcon icon;
        QRect geometry;
        bool isMinimized;
        bool isMaximized;
    };
    
    void addWindow(const WindowInfo &info);
    void removeWindow(WId windowId);
    void updateWindow(WId windowId, const WindowInfo &info);
    
    WindowInfo windowInfo(WId windowId) const;
    QList<WindowInfo> allWindows() const;
    
private:
    QMap<WId, WindowInfo> m_windows;
};
```

## Error Handling

### Error Categories

1. **Initialization Errors**
   - Qt initialization failure
   - Vulkan instance creation failure
   - Theme loading failure

2. **Runtime Errors**
   - File system access errors
   - Window creation errors
   - Rendering errors

3. **Resource Errors**
   - Out of memory
   - GPU resource exhaustion
   - File not found

### Error Handling Strategy

```cpp
// ErrorHandler.h
class ErrorHandler : public QObject {
    Q_OBJECT
    
public:
    enum ErrorSeverity {
        Info,
        Warning,
        Error,
        Critical
    };
    
    static void handleError(ErrorSeverity severity, 
                          const QString &message,
                          const QString &details = QString());
    
    static void logError(const QString &message);
    static void showErrorDialog(const QString &message);
    
signals:
    void errorOccurred(ErrorSeverity severity, const QString &message);
};
```

### Fallback Mechanisms

- **Vulkan Failure**: Fall back to software rendering (QPainter)
- **Theme Loading Failure**: Use default Qt style
- **Window Effects Failure**: Disable effects, use standard windows

## Testing Strategy

### Unit Testing

**Framework**: Qt Test

**Test Coverage**:
- All public methods of framework classes
- Theme loading and application
- Window creation and management
- File system operations

**Example**:

```cpp
// test_modernwindow.cpp
class TestModernWindow : public QObject {
    Q_OBJECT
    
private slots:
    void initTestCase();
    void testWindowCreation();
    void testTitleBarCustomization();
    void testModernEffects();
    void testWindowResize();
    void cleanupTestCase();
    
private:
    ModernWindow *m_window;
};
```

### Integration Testing

**Test Scenarios**:
- Qt Explorer file operations
- Taskbar window management
- Theme switching across applications
- Vulkan rendering pipeline

### Performance Testing

**Metrics**:
- Application startup time (< 1000ms)
- Window creation time (< 300ms)
- Frame rate (> 60 FPS)
- Memory usage (< 50MB overhead per app)

**Tools**:
- Qt Creator Profiler
- Vulkan validation layers
- Custom performance benchmarks

### UI Testing

**Framework**: Qt Test with QTest::qWait()

**Test Cases**:
- Button clicks and menu interactions
- Keyboard shortcuts
- Drag and drop operations
- Context menus

## Build System Integration

### CMake Configuration

```cmake
# CMakeLists.txt for Qt subsystem
cmake_minimum_required(VERSION 3.20)
project(ReactOS_Qt_Subsystem)

# Qt configuration
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Widgets
    Quick
)

# Vulkan configuration
find_package(Vulkan REQUIRED)

# Compiler flags
if(MSVC)
    add_compile_options(/W4 /WX)
else()
    add_compile_options(-Wall -Wextra -Werror)
endif()

# Qt Framework
add_subdirectory(src/qt_framework)

# System Components
add_subdirectory(src/explorer)
add_subdirectory(src/taskbar)
add_subdirectory(src/control_panel)
add_subdirectory(src/settings)

# Applications
add_subdirectory(src/apps/notepad)
add_subdirectory(src/apps/paint)
add_subdirectory(src/apps/calculator)
add_subdirectory(src/apps/taskmanager)

# Tests
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
```

### Component CMakeLists Example

```cmake
# src/explorer/CMakeLists.txt
add_executable(qtexplorer
    main.cpp
    qtexplorer.cpp
    qtexplorer.h
    navigationpane.cpp
    navigationpane.h
    contentpane.cpp
    contentpane.h
)

target_link_libraries(qtexplorer
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    ReactOSFramework
)

install(TARGETS qtexplorer
    RUNTIME DESTINATION bin
)
```

## Deployment Strategy

### Phase 1: Core Framework (Month 1-2)
- Implement ReactOSApplication
- Implement ModernWindow
- Implement VulkanWindow
- Create theme system

### Phase 2: System Components (Month 3-5)
- Migrate File Explorer
- Migrate Taskbar
- Migrate Control Panel
- Migrate System Settings

### Phase 3: Applications (Month 6-7)
- Migrate Notepad
- Migrate Paint
- Migrate Calculator
- Migrate Task Manager

### Phase 4: Polish and Optimization (Month 8-9)
- Performance optimization
- Bug fixes
- Documentation
- User testing

## Performance Considerations

### Memory Management
- Use Qt's parent-child ownership for automatic cleanup
- Implement lazy loading for large file lists
- Cache rendered icons and thumbnails

### Rendering Optimization
- Use Vulkan command buffer pooling
- Implement frustum culling for 3D effects
- Use Qt's graphics view framework for complex scenes

### Startup Optimization
- Lazy load Qt modules
- Defer Vulkan initialization until needed
- Use Qt Quick for faster UI loading

## Security Considerations

### Input Validation
- Validate all file paths
- Sanitize user input in text fields
- Validate theme file contents

### Resource Limits
- Limit maximum window count
- Limit Vulkan memory allocation
- Implement timeout for long operations

### Privilege Separation
- Run Qt applications with user privileges
- Separate system components from user applications
- Use Qt's security features (QSslSocket, etc.)

## Accessibility

### Qt Accessibility Support
- Use QAccessible for screen reader support
- Implement keyboard navigation for all UI
- Support high contrast themes
- Provide text alternatives for icons

### Keyboard Shortcuts
- Standard Windows shortcuts (Ctrl+C, Ctrl+V, etc.)
- Alt+Tab for window switching
- Win+E for Explorer
- Win+R for Run dialog

## Internationalization

### Qt Translation System
- Use Qt Linguist for translations
- Support RTL languages
- Locale-aware date/time formatting
- Unicode support throughout

## Monitoring and Logging

### Logging System

```cpp
// Logger.h
class Logger : public QObject {
    Q_OBJECT
    
public:
    enum LogLevel {
        Debug,
        Info,
        Warning,
        Error,
        Critical
    };
    
    static void log(LogLevel level, const QString &message);
    static void setLogFile(const QString &path);
    static void setLogLevel(LogLevel level);
    
private:
    static QFile *s_logFile;
    static LogLevel s_logLevel;
};
```

### Performance Monitoring

```cpp
// PerformanceMonitor.h
class PerformanceMonitor : public QObject {
    Q_OBJECT
    
public:
    void startFrame();
    void endFrame();
    
    double averageFPS() const;
    double averageFrameTime() const;
    
signals:
    void fpsChanged(double fps);
    void frameTimeChanged(double ms);
    
private:
    QElapsedTimer m_timer;
    QQueue<qint64> m_frameTimes;
};
```

## Migration Path

### Gradual Migration Strategy

1. **Coexistence Phase**
   - Qt and Win32 subsystems run in parallel
   - Users can choose which version to use
   - Default to Win32 for compatibility

2. **Transition Phase**
   - Qt becomes default for new installations
   - Win32 available as fallback
   - Migration tools for user settings

3. **Completion Phase**
   - Qt is primary subsystem
   - Win32 maintained for legacy support only
   - Full feature parity achieved

### User Migration Tools

```cpp
// SettingsMigrator.h
class SettingsMigrator : public QObject {
    Q_OBJECT
    
public:
    bool migrateFromWin32();
    bool exportToWin32();
    
    QStringList detectWin32Settings();
    bool importSettings(const QStringList &settings);
    
signals:
    void migrationProgress(int percent);
    void migrationComplete(bool success);
};
```

## Conclusion

This design provides a comprehensive architecture for migrating ReactOS to Qt + Vulkan while maintaining backward compatibility. The modular approach allows for incremental migration, reducing risk and allowing for continuous testing and validation throughout the process.
