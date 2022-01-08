--[[
******帮派公告展示*******

	-- by quanhuan
	-- 2016/4/25
]]


local FactionNoticeLayer = class("FactionNoticeLayer",BaseLayer)

function FactionNoticeLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionNotice")
end

function FactionNoticeLayer:initUI( ui )

	self.super.initUI(self, ui)

	self.btn_close = TFDirector:getChildByPath(ui, "btn_ok")
	self.txt_contect = TFDirector:getChildByPath(ui, "txt_contect")
	self.btn_close.logic = self
end

function FactionNoticeLayer:removeUI()
	self.super.removeUI(self)
end

function FactionNoticeLayer:registerEvents()
	self.super.registerEvents(self)

	ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
end

function FactionNoticeLayer:removeEvents()
    self.super.removeEvents(self)
end

function FactionNoticeLayer:setContentText(text)
	self.txt_contect:setText(text)
end

return FactionNoticeLayer