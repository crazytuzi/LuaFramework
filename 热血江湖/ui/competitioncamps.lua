module(..., package.seeall)

local require = require

local ui = require("ui/base")


wnd_competitionCamps = i3k_class("wnd_competitionCamps", ui.wnd_base)
--------------------------------------------------------------

local MEBER_ITEM = "ui/widgets/yyqcsfj1t" --成员item yyqcsfj1t

local RED_CAMPS = 1	--红方
local BLUE_CAMPS = 2 -- 蓝方

function wnd_competitionCamps:ctor()
	self._timeCount = 0
	self._endTime = i3k_game_get_time() + i3k_db_dual_meet.autoLeaveTime
end

function wnd_competitionCamps:refresh(joinTime)
	self._endTime = joinTime + i3k_db_dual_meet.autoLeaveTime
end

function wnd_competitionCamps:configure()
	local widgets = self._layout.vars
	self.operationFilter = widgets.scroll3
	self.campsForScroll = {}
	widgets.leaveBtn:onClick(self, self.onLeaveRoom)
	widgets.selecteRedBtn:onClick(self, self.onSelecteCamps, RED_CAMPS)
	widgets.selecteBlueBtn:onClick(self, self.onSelecteCamps, BLUE_CAMPS)
end

function wnd_competitionCamps:onUpdate(dTime)
	self._timeCount = self._timeCount + dTime
	if self._timeCount >= 1 then
		local haveTime = self._endTime - i3k_game_get_time()
		self._layout.vars.time:setText(i3k_get_string(18786, haveTime))
		if haveTime <= 0 then
			self:onCloseUI()
			g_i3k_ui_mgr:AddTask(self, {}, function(ui)
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18787))
				g_i3k_game_context:ResetCompetitionData()
			end, 1)
		end
		self._timeCount = 0
	end
end

function wnd_competitionCamps:onSelecteCamps(sender, camp)
	i3k_sbean.competition_select_camp(camp)
end

function wnd_competitionCamps:onLeaveRoom(sender)
	local fun = (function(ok)
		if ok then
			i3k_sbean.competition_leave_room()
		end
	end)
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18798), fun)
end

function wnd_create(layout, ...)
	local wnd = wnd_competitionCamps.new()
	wnd:create(layout)
	return wnd
end
