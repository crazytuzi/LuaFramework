--[[
******聊天消息时间分割线*******

	-- by david.dai
	-- 2014/06/24
]]

local TimeSpilt = class("TimeSpilt", BaseLayer)

function TimeSpilt:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.chat.TimeSpilt")
end

function TimeSpilt:initUI(ui)
	self.super.initUI(self,ui)

	--消息背景
	self.img_spilt_left	 		= TFDirector:getChildByPath(ui, 'img_spilt_left')
	self.img_spilt_right	 	= TFDirector:getChildByPath(ui, 'img_spilt_right')
	self.txt_timestamp	 		= TFDirector:getChildByPath(ui, 'txt_timestamp')

end

function TimeSpilt:removeUI()
	self.super.removeUI(self)
end

function TimeSpilt:setMessage(message)
	self.message = message
	self:refreshUI()
end

function TimeSpilt:setLogic(logiclayer)
	self.logic = logiclayer
end

function TimeSpilt:refreshUI()
	local message = self.message
	self.txt_timestamp:setText(message.expression)
end

function TimeSpilt:registerEvents()
	self.super.registerEvents(self)
end

function TimeSpilt:removeEvents()
    self.super.removeEvents(self)
end

function TimeSpilt:getSize()
	return self.ui:getSize()
end

return TimeSpilt
