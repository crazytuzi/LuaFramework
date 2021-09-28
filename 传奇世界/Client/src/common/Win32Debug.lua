--Author:		bishaoqing
--DateTime:		2016-04-26 19:37:24
--Region:		用来开启全局测试
require("src/CommonFunc")
local Win32Debug = class("Win32Debug")
local Key = 
{
	CTRL1 = 14;
	CTRL2 = 15;
	LEFT = 26;
	RIGHT = 27;
	UP = 28;
	DOWN = 29;
	F1 = 47;
	F2 = 48;
	F3 = 49;
	F4 = 50;
	F5 = 51;
	F6 = 52;
	F7 = 53;
	F8 = 54;
}

function Win32Debug:ctor( ... )
	-- body
	if not IsWin32() then
		return
	end
	if not self:IsActive() then
		return
	end
	self.m_pKeyListener = cc.EventListenerKeyboard:create();
	self.m_pKeyListener:registerScriptHandler( handler(self, self.OnKeyboardPressed), cc.Handler.EVENT_KEYBOARD_PRESSED );
	self.m_pKeyListener:registerScriptHandler( handler(self, self.OnKeyboardReleased), cc.Handler.EVENT_KEYBOARD_RELEASED );
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority( self.m_pKeyListener, 1);
end

function Win32Debug:OnKeyboardPressed( nKeyCode, event )
	print("OnKeyboardPressed")
end

function Win32Debug:OnKeyboardReleased( nKeyCode, event )
	print("OnKeyboardReleased")
	local path="src/layers/trade/tradeLayer"
	local function reloadFile()
		 package.loaded[path]=nil
		 package.loaded["src/layers/trade/tradeView"]=nil
	     require(path)
	     
	     getRunScene():removeChildByName("win32DebugNode")
	end
    if Key.F1 == nKeyCode then
		GetProFiCtr():StartProFi();
	elseif Key.F2 == nKeyCode then
		GetProFiCtr():StopProFi();
	elseif Key.F3 == nKeyCode then
        --动态刷新LUA界面
        reloadFile()
        local stWinSize = cc.Director:getInstance():getWinSize()
        --win32DebugNode=require(path).new(getRunScene())
        win32DebugNode=require(path).new({
				roleName = "xxx",
				level = 2,
			})
        win32DebugNode:setName("win32DebugNode")
        getRunScene():addChild(win32DebugNode)
	elseif Key.F4 == nKeyCode then
	    reloadFile()
	elseif Key.F5 == nKeyCode then
    elseif Key.F6 == nKeyCode then
	elseif Key.F7 == nKeyCode then
	elseif Key.F8 == nKeyCode then
	elseif Key.LEFT == nKeyCode then
	elseif Key.RIGHT == nKeyCode then
	elseif Key.UP == nKeyCode then
		
	elseif Key.DOWN == nKeyCode then
	end
end

function Win32Debug:OnDispose( ... )
	-- body
	if self.m_pKeyListener then
		ScriptHandlerMgr:getInstance():removeObjectAllHandlers(self.m_pKeyListener)
		self.m_pKeyListener = nil
	end
end

function Win32Debug:IsActive( ... )
	-- body
	if not IsWin32() then
		return false
	end
	return GetIniLoader():GetPrivateBool("Main", "Win32Debug") ~= false
end

return Win32Debug