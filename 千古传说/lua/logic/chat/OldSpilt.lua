--[[
******聊天消息新旧消息分割线*******

	-- by david.dai
	-- 2014/06/24
]]

local OldSpilt = class("OldSpilt", BaseLayer)

function OldSpilt:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.chat.OldSpilt")
end

function OldSpilt:initUI(ui)
	self.super.initUI(self,ui)

	--消息背景
	self.img_spilt_left	 		= TFDirector:getChildByPath(ui, 'img_spilt_left')
	self.img_spilt_right	 	= TFDirector:getChildByPath(ui, 'img_spilt_right')
	self.txt_timestamp	 		= TFDirector:getChildByPath(ui, 'txt_timestamp')

end

function OldSpilt:removeUI()
	self.super.removeUI(self)
end

function OldSpilt:setMessage(message)
	self.message = message
	self:refreshUI()
end

function OldSpilt:setLogic(logiclayer)
	self.logic = logiclayer
end

function OldSpilt:refreshUI()
	local message = self.message
	self.txt_timestamp:setText(message.expression)
end

function OldSpilt:registerEvents()
	self.super.registerEvents(self)
end

function OldSpilt:removeEvents()
    self.super.removeEvents(self)
end

function OldSpilt:getSize()
	return self.ui:getSize()
end

return OldSpilt