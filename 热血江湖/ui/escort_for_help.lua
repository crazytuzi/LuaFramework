-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_escort_for_help = i3k_class("wnd_escort_for_help", ui.wnd_base)

local QYXXT = "ui/widgets/qyxxt"

function wnd_escort_for_help:ctor()

end

function wnd_escort_for_help:configure(...)
	local close = self._layout.vars.close
	close:onClick(self,self.onClose)
	local clear_all = self._layout.vars.clear_all
	clear_all:onClick(self,self.ClearAll)
	self.scroll = self._layout.vars.scroll
end

function wnd_escort_for_help:onShow()

end

function wnd_escort_for_help:refresh()
	self:updateData()
end

function wnd_escort_for_help:updateData()
	self.scroll:removeAllChildren()

	local str = g_i3k_game_context:GetEscortForHelpStr()
	if #str == 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_EscortHelpTips)
	end

	for k,v in ipairs(str) do
		local _layer = require(QYXXT)()

		local name = v.name
		local mapID = v.location.mapID

		local mapName = i3k_db_dungeon_base[mapID].name
		local tmp_str = i3k_get_string(569,name,mapName)

		_layer.vars.desc:setText(tmp_str)
		local t = {id = v.id,location = v.location,line = v.line}
		_layer.vars.go_btn:onClick(self,self.onHelp,t)

		self.scroll:addItem(_layer)
	end

end

function wnd_escort_for_help:onHelp(sender,t)
	if i3k_check_resources_downloaded(t.location.mapID) then
		local function func()
			i3k_sbean.escort_on_help(t.id,t.location,t.line)
			g_i3k_game_context:RemoveEscortForHelpById(t.id)
		end
		g_i3k_game_context:CheckMulHorse(func)
	end
end

function wnd_escort_for_help:ClearAll(sender)
	g_i3k_game_context:RemoveAllEscortForHelpStr()
	self:updateData()
	g_i3k_ui_mgr:CloseUI(eUIID_EscortHelpTips)
end

function wnd_escort_for_help:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_EscortForHelp)
end

function wnd_create(layout, ...)
	local wnd = wnd_escort_for_help.new();
		wnd:create(layout, ...);

	return wnd;
end
