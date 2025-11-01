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
