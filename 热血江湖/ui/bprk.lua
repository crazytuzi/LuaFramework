-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_bprk = i3k_class("wnd_bprk", ui.wnd_base)

function wnd_bprk:ctor()
	
end

function wnd_bprk:configure(...)
	local createBangpai = self._layout.vars.create
	local join = self._layout.vars.join
	createBangpai:onTouchEvent(self, self.createCB)
	join:onTouchEvent(self, self.joinCB)
	self.join_faction = self._layout.vars.join_faction 
	self.join_faction:show()
	self.create_faction = self._layout.vars.create_faction 
	self.create_faction:show()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_bprk:onShow()
	
end

function wnd_bprk:onHide()
	
end

function wnd_bprk:refresh()
	self:updateData()
end 

function wnd_bprk:updateData()
	local my_lvl = g_i3k_game_context:GetLevel()
	if my_lvl >= i3k_db_common.faction.addLevel then
		self.join_faction:hide()
	end
	if my_lvl >= i3k_db_common.faction.createLevel then
		self.create_faction:hide()
	end
end 

function wnd_bprk:createCB(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		local needLvl = i3k_db_common.faction.createLevel
		local hero_lvl = g_i3k_game_context:GetLevel()
		if hero_lvl < needLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10000,needLvl))
			return 
		end
		g_i3k_ui_mgr:OpenUI(eUIID_CreateFaction)
		g_i3k_ui_mgr:RefreshUI(eUIID_CreateFaction)
	end
end

function wnd_bprk:joinCB(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		local needLvl = i3k_db_common.faction.addLevel
		local hero_lvl = g_i3k_game_context:GetLevel()
		if hero_lvl < needLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10031,needLvl))
			return 
		end
		local data = i3k_sbean.sect_list_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_list_res.getName())
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_bprk.new();
		wnd:create(layout, ...);

	return wnd;
end
