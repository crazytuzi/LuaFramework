-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_msg_box3 = i3k_class("wnd_msg_box3", ui.wnd_base)

function wnd_msg_box3:ctor()
	self.isShow=false
end

function wnd_msg_box3:configure()
	
	local useItemBtn = self._layout.vars.useItemBtn--圆钮
	useItemBtn:onClick(self,self.onRadioBtn)
	self._layout.vars.useItem:setVisible(false)--对勾
	local ok=self._layout.vars.ok
	ok:onClick(self, self.onOK)
	local cancel=self._layout.vars.cancel
	cancel:onClick(self, self.onCancel)
	local itemCount = self._layout.vars.itemCount
end

function wnd_msg_box3:onRadioBtn(sender)
	if self.isShow then
		self.isShow = false
		self._layout.vars.useItem:setVisible(false)
	else
		self.isShow = true
		self._layout.vars.useItem:setVisible(true)
	end
	local callbackRadioButton = self.__callbackRadioButton
	if callbackRadioButton then
		callbackRadioButton(self.isShow, self._layout.vars.ok, self._layout.vars.cancel)
	end
end

function wnd_msg_box3:onOK(sender)
	local callback = self.__callback
	if callback then
		callback(true,self.isShow)
	end
end

function wnd_msg_box3:onCancel(sender)
	local callback = self.__callback
	if callback then
		callback(false,self.isShow)
	end
end

function wnd_msg_box3:refresh(yesName, noName, msg, rtext,callback,callbackRadioButton, defalutRadioShow)
	local yesLabel = self._layout.vars.yes_name
	yesLabel:setText(yesName)
	local noLabel = self._layout.vars.no_name
	noLabel:setText(noName)
	local desc = self._layout.vars.desc
	desc:setText(msg)
	local itemCount = self._layout.vars.itemCount
	itemCount:setText(rtext)
	self.isShow = defalutRadioShow == true
	self._layout.vars.useItem:setVisible(self.isShow)
	self.__callback = callback
	self.__callbackRadioButton = callbackRadioButton
end

function wnd_create(layout)
	local wnd = wnd_msg_box3.new()
	wnd:create(layout)
	return wnd
end
