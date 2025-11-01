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
