-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dungeon_rule = i3k_class("wnd_faction_dungeon_rule", ui.wnd_base)

local _LAYER_BFGZT = "ui/widgets/bfgzt"

function wnd_faction_dungeon_rule:ctor()
	
end

function wnd_faction_dungeon_rule:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.item_scroll = self._layout.vars.item_scroll
end

function wnd_faction_dungeon_rule:onShow()
	
end

function wnd_faction_dungeon_rule:refresh()
	self:updateData()
end 

function wnd_faction_dungeon_rule:updateData()
	local _layer = require(_LAYER_BFGZT)()
	self.item_scroll:addItem(_layer)
end 


function wnd_faction_dungeon_rule:onHide()
	
end

--[[function wnd_faction_dungeon_rule:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonRule)
	end
end--]]

function wnd_create(layout,...)
	local wnd = wnd_faction_dungeon_rule.new()
	wnd:create(layout,...)
	return wnd
end