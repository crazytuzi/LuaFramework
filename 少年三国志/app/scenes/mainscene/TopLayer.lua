--TopLayer.lua

local FunctionLevelConst = require("app.const.FunctionLevelConst")
local storage = require("app.storage.storage")

local TopLayer = class("TopLayer", UFCCSNormalLayer)


function TopLayer.create( ... )
	return TopLayer.new("ui_layout/mainscene_topLayer.json")
end

function TopLayer:ctor( ... )
	self._chatIsShow = false
	self._chatLayer = nil
	self._isGuiding = false
	self._originShowStatus = true
	self._hasBeenMoved = false
	self._btnShowStatus = true
	self._defaultChatChannelId = 0

	self.super.ctor(self, ...)

	self._btnSize = self:getWidgetByName("Button_chat"):getSize()
	self._screenSize = CCDirector:sharedDirector():getWinSize()
	self:setClickSwallow(true)
	uf_notifyLayer:getModelNode():addChild(self)

end

function TopLayer:onLayerLoad( ... )
	self:registerBtnClickEvent("Button_chat", function ( ... )
		if not self._hasBeenMoved then 
			self:onChatClick()
		end
	end)
	self:registerWidgetTouchEvent("Button_chat", function ( widget, eventType )
		if eventType == TOUCH_EVENT_MOVED then 
			if widget and (self._hasBeenMoved or (not self._hasBeenMoved and not widget:isFocused())) then 
				self._hasBeenMoved = true
				local pos = widget:getTouchMovePos()
				if (self._screenSize.width - self._btnSize.width/2 < pos.x) then 
					pos.x = self._screenSize.width - self._btnSize.width/2
				elseif (pos.x < self._btnSize.width/2) then 
					pos.x = self._btnSize.width/2
				end
				if (self._screenSize.height - self._btnSize.height/2 < pos.y) then 
					pos.y = self._screenSize.height - self._btnSize.height/2
				elseif pos.y < self._btnSize.height/2 then 
					pos.y = self._btnSize.height/2
				end

				widget:setPosition(widget:getTouchMovePos())
			end
		elseif eventType == TOUCH_EVENT_BEGAN then 
			self._hasBeenMoved = false
		elseif eventType == TOUCH_EVENT_ENDED then 
			self:_saveChatPos(widget:getTouchMovePos())
		elseif eventType == TOUCH_EVENT_CANCELED then 
			if self._hasBeenMoved then 
				self:_saveChatPos(widget:getTouchMovePos())
			end
		end
	end)

	self:_initChatBtnPos()
	self:show(true)
end

function TopLayer:onLayerEnter( ... )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_GUIDE_START, self._onGuideStart, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_GUIDE_END, self._onGuideEnd, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MSG_DIRTY_FLAG_CHANGED, self._onReceiveChatFlagChange, self)
	--uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SCENE_CHANGED, self._onReceiveSceneChange, self)
end

function TopLayer:_onReceiveSceneChange( sceneName )
	--self._chatLayer = nil
	--self._chatIsShow = false
end

function TopLayer:_initChatBtnPos( ... )
	--local posx = CCUserDefault:sharedUserDefault():getIntegerForKey("chat_pos_x", 0)
	--local posy = CCUserDefault:sharedUserDefault():getIntegerForKey("chat_pos_y", 0)
	local info = storage.load(storage.path("setting.data"))
	if info and (type(info.chat_pos_x) == "number" or type(info.chat_pos_y) == "number") then 
		local widget = self:getWidgetByName("Button_chat")
		if widget then 
			local widgetSize = widget:getSize()
			local winSize = CCDirector:sharedDirector():getWinSize()
			if info.chat_pos_x < widgetSize.width/2 then 
				info.chat_pos_x = widgetSize.width/2
			elseif info.chat_pos_x > winSize.width - widgetSize.width/2 then
				info.chat_pos_x = winSize.width - widgetSize.width/2
			end
			if info.chat_pos_y < widgetSize.height/2 then 
				info.chat_pos_y = widgetSize.height/2
			elseif info.chat_pos_y > winSize.height - widgetSize.height/2 then
				info.chat_pos_y = winSize.height - widgetSize.height/2
			end

			widget:setPosition(ccp(info.chat_pos_x, info.chat_pos_y))
		end
	end
	
	local defaulsShowChat = (G_Setting:get("default_show_chat") == "1")
	local showBtn = (info and info.show_chat_enable and info.show_chat_enable == 1)
	if defaulsShowChat then 
		showBtn = not (info and info.show_chat_enable and info.show_chat_enable ~= 1) 
	end
	self:showChatBtn(showBtn)
end

function TopLayer:_saveChatPos( pos )
	local info = storage.load(storage.path("setting.data"))
	if info and pos then 
		info.chat_pos_x = pos.x
		info.chat_pos_y = pos.y
		storage.save(storage.path("setting.data"), info )
	end
end

function TopLayer:_onReceiveChatFlagChange( isDirty )
    self:showWidgetByName("Image_tip_new", isDirty)
    local btn = self:getButtonByName("Button_chat")
    if btn then 
    	btn:loadTextureNormal(isDirty and "ui/mainpage/icon-liaotian-float-highlight.png" or "ui/mainpage/icon-liaotian-float-gray.png")
    end
end

function TopLayer:_onGuideStart( ... )
	self._isGuiding = true
	self:_doUpdateShowStatus()
end

function TopLayer:_onGuideEnd( ... )
	self._isGuiding = false

	self:_doUpdateShowStatus()
end

function TopLayer:_doUpdateShowStatus( ... )
	self:setVisible(not self._isGuiding and self._originShowStatus)
end

function TopLayer:show( show )
	if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CHAT) then 
		show = false
	end
	self._originShowStatus = show
	self:_doUpdateShowStatus()
end

function TopLayer:hideTemplate( ... )
	if not self._originShowStatus then 
		return 
	end

	self._originShowStatus = false
	self:_doUpdateShowStatus()
	self._originShowStatus = true
end

function TopLayer:showTemplate( ... )
	if not self._originShowStatus then
		self._originShowStatus = true
		self:_doUpdateShowStatus()
		self._originShowStatus = false
	end

	if not self._btnShowStatus then
		self._btnShowStatus = true
		self:_updateChatButton()
		self._btnShowStatus = false
	end
end

function TopLayer:resumeStatus( ... )
	self:_doUpdateShowStatus()
	self:_updateChatButton()
end

function TopLayer:showChatBtn( show )
	if IS_HEXIE_VERSION then 
		show = false
	end
	self._btnShowStatus = show
	self:_updateChatButton()
end

function TopLayer:_updateChatButton( show )
	self:showWidgetByName("Button_chat", self._btnShowStatus)
end

function TopLayer:chatToSomeone( param )
	self:showChat(2, param)
end

function TopLayer:showChat( channel, param )
    if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CHAT) then 
        return 
    end

    channel = channel or 1
	if self._chatIsShow and self._chatLayer then 
		self._chatLayer:showWithChannel(channel, param)
		return 
	end
    self._chatLayer = require("app.scenes.chat.ChatLayer").new("ui_layout/ChatPanel_MainPanel.json", 
    	Colors.modelColor, channel, param, function ( ... )
    	self._chatIsShow = false
    	self._chatLayer = nil
    end)
    self._chatIsShow = true
end

function TopLayer:onChatClick( ... )
	if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CHAT) then 
        return 
    end

	if self._chatIsShow then
		if self._chatLayer then 
			self._chatLayer:animationToClose()
			self._chatIsShow = false
			self._chatLayer = nil
		end  
		return 
	end
    local defaultChannel = 1
    local arr = G_HandlersManager.chatHandler:getNewMsgChannel() or {}
    if #arr > 0 then 
        defaultChannel = arr[1] or 1
    end
    if self._defaultChatChannelId > 0 then 
    	defaultChannel = self._defaultChatChannelId
    end
    self._chatLayer = require("app.scenes.chat.ChatLayer").new("ui_layout/ChatPanel_MainPanel.json", 
    	Colors.modelColor, defaultChannel, nil, function ( ... )
    	self._chatIsShow = false
    	self._chatLayer = nil
    end)
    self._chatIsShow = true
end

function TopLayer:resetChatDefaultChannel( channelId )
	-- channelId must be in range 1 to 4
	self._defaultChatChannelId = channelId or -1
end

return TopLayer

