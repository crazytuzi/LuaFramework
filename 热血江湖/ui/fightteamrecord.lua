-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamRecord = i3k_class("wnd_fightTeamRecord", ui.wnd_base)

function wnd_fightTeamRecord:ctor()

end

function wnd_fightTeamRecord:configure(...)
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	self.dismissBtn = widgets.dismissBtn
widgets.dismissBtn:onClick(self, self.onDismiss)
	self.scroll = widgets.scroll
end

function wnd_fightTeamRecord:refresh()
	self:loadScroll()
	self.dismissBtn:setVisible(g_i3k_game_context:getScheduleStage() <= f_FIGHTTEAM_STAGE_QUALIFY) --海选赛才显示
	self:setLabel()
end

function wnd_fightTeamRecord:loadScroll()
	local record = g_i3k_db.i3k_db_get_fight_team_record()
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local annText = require("ui/widgets/wudaohuizjxxt")()
		annText.vars.text:setText(record)
		self.scroll:addItem(annText)
		g_i3k_ui_mgr:AddTask(self, {annText}, function(ui)
			local textUI = annText.vars.text
			local size = annText.rootVar:getContentSize()
			local height = textUI:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			annText.rootVar:changeSizeInScroll(self.scroll, width, height, true)
		end, 1)
	end, 1)
end
function wnd_fightTeamRecord:setLabel()
	local widgets = self._layout.vars
	if g_i3k_game_context:getScheduleStage() > f_FIGHTTEAM_STAGE_QUALIFY then
		local group = g_i3k_game_context:getDefaultGroupID()
		if group then		
			local str = i3k_get_string(1818, g_i3k_db.i3k_db_get_fightTeam_group_name(group))
			widgets.groupInfo:setText(str)
			widgets.groupInfo:show()
		end
	else
		widgets.groupInfo:hide()
	end
end

function wnd_fightTeamRecord:onDismiss(sender)
	if g_i3k_game_context:getMatchState() == g_FIGHT_TEAM_MATCH then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1244))
	end
	
	if not g_i3k_game_context:getIsFightTeamLeader() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1240))
	end

	local fun = (function(ok)
		if ok then
			i3k_sbean.fightteam_dismiss_request()
		end
	end)
	local desc = i3k_get_string(1241, i3k_db_fightTeam_base.team.maxJoinTimes)
	g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", desc, fun)
end

function wnd_create(layout, ...)
	local wnd = wnd_fightTeamRecord.new();
		wnd:create(layout, ...);
	return wnd;
end
