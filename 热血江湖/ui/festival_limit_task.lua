-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_festival_limit_task = i3k_class("wnd_festival_limit_task", ui.wnd_base)

function wnd_festival_limit_task:ctor()
	self._activityId = 0
end

function wnd_festival_limit_task:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.cancelBtn:onClick(self, self.onCloseUI)
	self._layout.vars.sureBtn:onClick(self, self.onSureBtn)
end

function wnd_festival_limit_task:refresh(id)
	self._activityId = id
	local actCfg = i3k_db_festival_cfg[id]
	self._layout.vars.need_lvl:setText(i3k_get_string(17799, actCfg.openLvl))
	self._layout.vars.need_activity:setText(i3k_get_string(17800, actCfg.needActivity))
	self._layout.vars.time:setText(g_i3k_db.i3k_db_get_festival_limit_time(id))
	self._layout.vars.desc:setText(i3k_get_string(17802))
	self._layout.vars.ok_text:setText(i3k_get_string(17805))
end

function wnd_festival_limit_task:onSureBtn(sender)
	local actCfg = i3k_db_festival_cfg[self._activityId]
	if g_i3k_game_context:GetLevel() < actCfg.openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17803, actCfg.openLvl))
		return
	end
	if g_i3k_game_context:GetScheduleInfo().activity < actCfg.needActivity then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17804, actCfg.needActivity))
		return
	end
	if not g_i3k_db.i3k_db_is_in_festival_task(self._activityId) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17806))
		return
	end
	local data = g_i3k_game_context:getFestivalLimitTask()
	for k, v in pairs(data) do
		if self._activityId == v.festivalId then
			if v.dayAccept == 0 then
				if #i3k_db_festival_cfg[self._activityId].taskGroupId > v.lastAcceptIndex then
					if not v.curTask then
						i3k_sbean.festival_task_enter(self._activityId, v.lastAcceptIndex + 1)
						self:onCloseUI()
					else
						if v.curTask.index == 1 and v.curTask.state == 0 then
							g_i3k_game_context:GetFestivalTaskDialogue(v.curTask.groupId, 1)
							self:onCloseUI()
						else
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17807))
						end
					end
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17813))
				end
			else
				if v.curTask then
					if v.curTask.index == 1 and v.curTask.state == 0 then
						g_i3k_game_context:GetFestivalTaskDialogue(v.curTask.groupId, 1)
						self:onCloseUI()
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17807))
					end
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17808))
				end
			end
			return
		end
	end
	i3k_sbean.festival_task_enter(self._activityId, 1)
	self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_festival_limit_task.new()
	wnd:create(layout)
	return wnd
end