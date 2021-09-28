-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_biography_task = i3k_class("wnd_biography_task", ui.wnd_base)

function wnd_biography_task:ctor()
	self._info = {}
	self._careerId = 1
end

function wnd_biography_task:configure()
	self._layout.vars.doTaskBtn:onClick(self, self.doTask)
	self._layout.vars.skillBtn:onClick(self, self.OpenSkill)
end

function wnd_biography_task:refresh()
	self._layout.vars.titleName:setText(i3k_get_string(18534))
	self._careerId = g_i3k_game_context:getCurBiographyCareerId()
	self._info = g_i3k_game_context:getBiographyCareerInfo()
	if self._info[self._careerId] and self._info[self._careerId].taskId > 0 then
		local cfg = i3k_db_wzClassLand_task[self._careerId][self._info[self._careerId].taskId]
		local value = self._info[self._careerId].taskVal
		local state = self._info[self._careerId].taskState
		local isFinish = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
		self._layout.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, value, state, isFinish))
		self._layout.vars.percent:setPercent((self._info[self._careerId].taskId - 1) / table.nums(i3k_db_wzClassLand_task[self._careerId]) * 100)
		self._layout.vars.taskName:setText(cfg.prename..cfg.name)
		self._layout.vars.taskName:show()
	else
		self._layout.vars.taskDesc:setText("已完成，请回大地图")
		self._layout.vars.percent:setPercent(100)
		self._layout.vars.taskName:hide()
	end
end

function wnd_biography_task:getCommonTaskDesc(cfg, value, state, isFinish)
	local desc = g_i3k_db.i3k_db_get_task_specialized_desc(cfg, isFinish)
	desc = g_i3k_db.i3k_db_get_task_desc(cfg.type, cfg.arg1, cfg.arg2, value, isFinish, desc)
	if state == 0 then
		if cfg.getTaskNpcID and cfg.getTaskNpcID ~= 0 then
			desc = g_i3k_db.i3k_db_get_task_desc(12, cfg.getTaskNpcID, nil, nil, false, nil)
		end
	else
		desc = isFinish and g_i3k_db.i3k_db_get_task_finish_reward_desc(cfg) or desc
	end
	return desc or ""
end

function wnd_biography_task:doTask(sender)
	if self._info[self._careerId] and self._info[self._careerId].taskId > 0 then
		local cfg = i3k_db_wzClassLand_task[self._careerId][self._info[self._careerId].taskId]
		local value = self._info[self._careerId].taskVal
		local state = self._info[self._careerId].taskState
		local isFinish = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
		if state == 0 then
			if cfg.getTaskNpcID == 0 then
				g_i3k_game_context:OpenGetTaskDialogue(cfg, TASK_CATEGORY_BIOGRAPHY)
			else
				self:transportToNpc(cfg.getTaskNpcID)
			end
			return
		end
		if state >= 1 and isFinish then
			self:doFinishTask(cfg)
			return
		end
		g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_BIOGRAPHY, cfg)
	else
		
	end
end

function wnd_biography_task:transportToNpc(npcID)
	local point1 = g_i3k_db.i3k_db_get_npc_pos(npcID);
	local mapID = g_i3k_db.i3k_db_get_npc_map_id(npcID);
	local point = g_i3k_game_context:getNPCRandomPos(npcID)
	local needValue = {flage = 1, mapId = mapID, areaId = npcID, pos = point, npcPos = point1}
	local isCan = g_i3k_game_context:doTransport(needValue)
	if not isCan then
		g_i3k_game_context:SeachPathWithMap(mapID, point, TASK_CATEGORY_BIOGRAPHY, nil, needValue)
	end
end

function wnd_biography_task:doFinishTask(cfg)
	local npcID = cfg.finishTaskNpcID
	if npcID == 0 then
		g_i3k_game_context:OpenFinishTaskDialogue(cfg, TASK_CATEGORY_BIOGRAPHY)
	else
		self:transportToNpc(npcID)
	end
end

function wnd_biography_task:OpenSkill(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BiographySkills)
	g_i3k_ui_mgr:RefreshUI(eUIID_BiographySkills)
end

function wnd_create(layout)
	local wnd = wnd_biography_task.new()
	wnd:create(layout)
	return wnd
end
