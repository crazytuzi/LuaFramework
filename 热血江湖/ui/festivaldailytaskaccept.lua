--活动任务接受任务界面 
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/festivalTaskAcceptBase");

-------------------------------------------------------
wnd_festivalDailyTaskAccept = i3k_class("wnd_festivalDailyTaskAccept", ui.wnd_festivalTaskAcceptBase)

function wnd_festivalDailyTaskAccept:ctor()

end

function wnd_festivalDailyTaskAccept:configure()
	local widgets = self._layout.vars
	widgets.abandonBtn:onClick(self, self.onGiveUpBtn)
	widgets.go_btn:onClick(self, self.onTaskAcceptButotn)
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_festivalDailyTaskAccept:refresh(npcID)
	self.npcId = npcID
	local taskCfg = g_i3k_db.i3k_db_new_festival_get_taskCfg_by_npcid(npcID)
	
	self:SetTaskName(taskCfg.taskName)
	self:SetTaskDesc(taskCfg.des)
	-- local is_ok = self:getTaskIsfinish(taskCfg.taskConditionType, taskCfg.args[1], taskCfg.args[2], cfg.value)
	local desc = g_i3k_db.i3k_db_get_task_desc(taskCfg.taskConditionType, taskCfg.args[1], taskCfg.args[2], 0, false)
	self:SetTaskKillDesc(desc)
	self:localScroll(taskCfg.rewards, self._layout.vars.scroll)
end

function wnd_festivalDailyTaskAccept:onTaskAcceptButotn(sender)
	if not g_i3k_db.i3k_db_is_in_new_festival_task() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19078))
        g_i3k_ui_mgr:CloseUI(eUIID_FestivalTaskAccept)
		return
	end
	i3k_sbean.new_festival_time_limi_task_start(self.npcId)
end

function wnd_create(layout, ...)
	local wnd = wnd_festivalDailyTaskAccept.new()
	wnd:create(layout, ...)
	return wnd;
end
