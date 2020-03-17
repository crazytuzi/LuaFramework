--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/20
-- Time: 17:08
-- 应用程序的基本部分，主要是实现应用程序相关的事件和设置
_G.classlist['CBaseApp'] = 'CBaseApp'
_G.CBaseApp = {}
_G.CBaseApp.objName = 'CBaseApp'
function CBaseApp:Create(objEvent)
    local obj = {};
    setmetatable(obj,{__index = CBaseApp});
    --注册事件
    _app:onActive(objEvent.OnActive);			--设置窗口激活或挂起时的回调函数。
    _app:onResize(objEvent.OnResize);			-- 设置窗口大小改变时的回调函数。
    _app:onIdle(objEvent.OnIdle);			  	-- 设置程序每帧的回调函数。
    _app:onExit(objEvent.OnExit);			  	-- 设置程序退出的回调函数。

    _app:onMouseMove(objEvent.OnMouseMove);		-- 设置鼠标移动的回调函数。
    _app:onMouseDown(objEvent.OnMouseDown);		-- 设置鼠标按下时的回调函数。
    _app:onMouseUp(objEvent.OnMouseUp);			-- 设置鼠标抬起时的回调函数。
    _app:onMouseDbclick(objEvent.OnMouseDbclick);	-- 设置鼠标双击的回调函数。
    _app:onMouseWheel(objEvent.OnMouseWheel);	-- 设置鼠标滚轮滚动时的回调函数。
    _app:onKeyDown(objEvent.OnKeyDown);			-- 设置键盘按键按下时的回调函数。
    _app:onKeyUp(objEvent.OnKeyUp);			 	-- 设置键盘按键抬起时的回调函数。
    _app:onChar(objEvent.OnChar);			  	-- 设置键盘输入字符时的回调函数。
    _app:onDrag(objEvent.OnDrag);			  	-- 设置拖动文件到程序时的回调函数。
	_app:onCloseWindow(objEvent.onCloseWindow)  -- 设置窗口被关闭时的回调函数
 
    return obj;
end;
