-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_promoteSteed = i3k_class("wnd_promoteSteed", ui.wnd_base)

function wnd_promoteSteed:ctor()
	
end

function wnd_promoteSteed:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_promoteSteed:refresh(info)
	local widgets = self._layout.vars
	widgets.practice_btn:onClick(self, self.openPractice, info.id, info.power)
	widgets.star_btn:onClick(self, self.openStar, info)
end

function wnd_promoteSteed:openPractice(sender, id, power)
	local info = g_i3k_game_context:getSteedInfoBySteedId(id)
	g_i3k_ui_mgr:OpenUI(eUIID_SteedPractice)
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedPractice, id, info, power)
	--g_i3k_ui_mgr:CloseUI(eUIID_SteedRank)
	g_i3k_ui_mgr:CloseUI(eUIID_PromoteSteed)
end

function wnd_promoteSteed:openStar(sender, info)
	if i3k_db_steed_star[info.id][info.starLv+1] then
		g_i3k_logic:OpenSteedStarUI(info.id)
		--g_i3k_ui_mgr:CloseUI(eUIID_SteedRank)
		g_i3k_ui_mgr:CloseUI(eUIID_PromoteSteed)
	else
	    g_i3k_ui_mgr:PopupTipMessage("您当前星级已满")
	end
end

function wnd_create(layout)
	local wnd = wnd_promoteSteed.new()
	wnd:create(layout)
	return wnd
end
