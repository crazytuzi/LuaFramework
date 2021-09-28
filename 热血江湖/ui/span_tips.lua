-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/chatBase");

require("i3k_ui_mgr")

-------------------------------------------------------
wnd_span_tips = i3k_class("wnd_span_tips", ui.wnd_chatBase)

function wnd_span_tips:ctor( )
	self.isTips = 1
	self.isCmd = 1
	self._chatState = 1
	self.message = ""
	self.roleId = 1
end

function wnd_span_tips:configure( )
	local widgets = self._layout.vars
	self.ok = widgets.ok
	self.ok:onClick(self,self.sendMessage)
	self.quxiao = widgets.quxiao
	self.quxiao:onClick(self,self.onCloseUI)
	self.tips_btn = widgets.tips_btn
	self.tips_btn:onClick(self,self.SetIsTips)
	self.tips_img = widgets.tips_img
end

function wnd_span_tips:refresh(isCmd,_chatState,message,roleId)
	self.isCmd = isCmd 
	self._chatState = _chatState
	self.message = message
	self.roleId = roleId
end

function wnd_span_tips:sendMessage(sender)
	local zyfNum = self:getZyfNum()
	if zyfNum > 0 then
		self:checkInput(self.isCmd,self._chatState,self.message,self.roleId,nil,nil,self.isTips)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(791))  --真言道具
	end
end

function wnd_span_tips:SetIsTips(sender)
	if self.isTips == 1 then
		self.isTips = 0
		self.tips_img:show()
	else
		self.isTips = 1
		self.tips_img:hide()
	end
end

function wnd_create(layout)
	local wnd = wnd_span_tips.new()
	wnd:create(layout)
	return wnd
end
