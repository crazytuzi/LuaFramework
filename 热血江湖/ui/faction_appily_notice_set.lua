-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_appily_notice_set = i3k_class("wnd_faction_appily_notice_set", ui.wnd_base)


local LAYER_BPSZT = "ui/widgets/bpszt"

local LEVEL = i3k_db_common.faction.addLevel

function wnd_faction_appily_notice_set:ctor()
	self._state = 0
end

function wnd_faction_appily_notice_set:configure(...)
	local cancel = self._layout.vars.cancel 
	cancel:onClick(self,self.onCncael)
	local ok = self._layout.vars.ok
	ok:onClick(self,self.onOk) 
	
	local open_btn = self._layout.vars.open_btn 
	open_btn:onClick(self,self.onOpen)
	local close_btn = self._layout.vars.close_btn 
	close_btn:onClick(self,self.onClose)
	
	self.open_icon = self._layout.vars.open_icon 
	self.close_icon = self._layout.vars.close_icon 
	local open_str = self._layout.vars.open_str 
	open_str:setText("开启推送")
	local close_str = self._layout.vars.close_str 
	close_str:setText("关闭推送")
end

function wnd_faction_appily_notice_set:onShow()
end

function wnd_faction_appily_notice_set:refresh()
	self._state = g_i3k_game_context:GetFactionIsOpenNoticeState()
	self:updateIcon(self._state)
end 

function wnd_faction_appily_notice_set:updateIcon(state)
	self.open_icon:setVisible(state == 1)
	self.close_icon:setVisible(state == 0)
end 


function wnd_faction_appily_notice_set:onOpen(sender)
	self._state = 1
	self:updateIcon(1)
end 

function wnd_faction_appily_notice_set:onClose(sender)
	self._state = 0
	self:updateIcon(0)
end 

function wnd_faction_appily_notice_set:onCncael(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionAppilyNoticeSet)
end 

function wnd_faction_appily_notice_set:onOk(sender)
	i3k_sbean.open_notice(self._state)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionAppilyNoticeSet)
end 




function wnd_create(layout, ...)
	local wnd = wnd_faction_appily_notice_set.new()
	wnd:create(layout, ...)

	return wnd
end

