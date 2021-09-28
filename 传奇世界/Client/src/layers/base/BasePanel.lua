--Author:		bishaoqing
--DateTime:		2016-05-12 15:18:40
--Region:		基类窗口
local BasePanel = class( "BasePanel" );
local CommDef = require("src/config/CommDef")
function BasePanel:ctor( pParent, nZOrder )
	self.m_pParent = pParent;
	self.m_bClosed = false;
	self.m_nZOrder = nZOrder or CommDef.ZVALUE_UI

	self:AddEvent()
	self:InitUI();
end

function BasePanel:InitUI()
	-- body
	self.m_pRoot = cc.Node:create()
	if nil ~= self.m_pRoot then
		self.m_pParent = self.m_pParent or getRunScene()
		if nil == self.m_nZOrder then
			self.m_pParent:addChild( self.m_pRoot );
		else
			self.m_pParent:addChild( self.m_pRoot, self.m_nZOrder );
		end
	end
	self.m_uiRoot = cc.Layer:create()
    self.m_pRoot:registerScriptHandler(function(event)
		if event == "exit" then
			self:Dispose()
		end
	end)
	-- self.m_uiRoot:ignoreAnchorPointForPosition(false)
	-- self.m_uiRoot:setAnchorPoint(cc.p(0, 0))
	self.m_pRoot:addChild(self.m_uiRoot)
	self.m_uiRoot:setContentSize( cc.Director:getInstance():getWinSize() )
	-- self.eventListener = GetUIHelper():AddTouchEventListener(true, self.m_uiRoot, handler(self, self.OnBgTouchBegan), handler(self, self.OnBgTouchEnd))
	-- self.eventListener = cc.EventListenerTouchOneByOne:create()
 --    self.eventListener:setSwallowTouches(true)
 --    self.eventListener:registerScriptHandler(handler(self, self.OnBgTouchBegan),cc.Handler.EVENT_TOUCH_BEGAN )
 --    self.eventListener:registerScriptHandler(handler(self, self.OnBgTouchEnd),cc.Handler.EVENT_TOUCH_ENDED )
 --    local eventDispatcher = self.m_uiRoot:getEventDispatcher()
 --    eventDispatcher:addEventListenerWithSceneGraphPriority(self.eventListener, self.m_uiRoot)
end

function BasePanel:OnDispose()
end

function BasePanel:Dispose()
	print("BasePanel:Dispose",self.__cname)
	self:RemoveEvent()
	self:OnDispose();
end

function BasePanel:setVisible( b )
	if not IsNodeValid(self.m_pRoot) then
		return ;
	end
	self.m_pRoot:setVisible(b)
end

function BasePanel:isVisible()
	return (IsNodeValid(self.m_pRoot and self.m_pRoot:isVisible()))
end

function BasePanel:Close()    
	if IsNodeValid(self.m_pRoot) then
		removeFromParent(self.m_pRoot, self.m_funcCloseCallback)
		-- if nil ~= self.m_funcCloseCallback then
		-- 	self.m_funcCloseCallback();
		-- 	self.m_funcCloseCallback = nil;
		-- end
		-- if nil ~= self.m_pRoot:getParent() then
		-- 	self.m_pRoot:removeFromParent();
		-- end
		self.m_pRoot = nil;
		-- self:Dispose();
	end
end
function BasePanel:IsClosed()
	return ( nil == self.m_pRoot );
end

function BasePanel:OnClose( sender, eventType )
	self:Close();
end

function BasePanel:SetCloseCallback( funcCallback )
	self.m_funcCloseCallback = funcCallback;
end

function BasePanel:OnBgTouchBegan( touch, event )
	-- body
	return true
end

function BasePanel:OnBgTouchEnd( touch, event )
	if nil ~= self.m_bgCallback then
		self.m_bgCallback();
	end
	self:Close();
end

function BasePanel:RegBgTouchCallback( callback )
	self.m_bgCallback = callback;
end

function BasePanel:AddEvent( ... )
	-- body
end

function BasePanel:RemoveEvent( ... )
	-- body
	-- if self.eventListener then
	-- 	ScriptHandlerMgr:getInstance():removeObjectAllHandlers(self.eventListener)
	-- 	self.eventListener = nil
	-- end
end

function BasePanel:GetRoot( ... )
	-- body
	return self.m_pRoot
end

function BasePanel:GetUIRoot( ... )
	-- body
	return self.m_uiRoot
end

return BasePanel;

--endregion
