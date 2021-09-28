-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_field_subline_task = i3k_class("wnd_field_subline_task", ui.wnd_base)

local LAYER_DB5T = "ui/widgets/db5t"

function wnd_field_subline_task:ctor()
	self._npcId = 0
end

function wnd_field_subline_task:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_field_subline_task:refresh(npcId)
	self._npcId = npcId
	local data = i3k_db_npc[npcId]
	local modelId = g_i3k_db.i3k_db_get_npc_modelID(npcId)
	if npcId == eExpTreeId then
		modelId = i3k_db_exptree_common.npcId
	end
	ui_set_hero_model(self._layout.vars.npcmodule, modelId)
	self._layout.vars.npcName:setText(data.remarkName)
	
	local groupId = data.exchangeId[1]
	self._layout.vars.btn_scroll:removeAllChildren()
	local taskData = g_i3k_game_context:getSubLineIdAndValueBytype(groupId)
	if (not taskData) or (taskData.id == 1 and taskData.state == 0) then
		self._layout.vars.dialogue:setText(data.desc0)
		local children = self._layout.vars.btn_scroll:addChildWithCount(LAYER_DB5T, 2, 2)
		local taskCfg = i3k_db_subline_task[groupId][1]
		for k, v in ipairs(children) do
			if k == 1 then
				v.vars.select1_btn:onClick(self, self.onChooseTask, true)
				v.vars.name:setText(taskCfg.getBtnText)
			else
				v.vars.select1_btn:onClick(self, self.onChooseTask, false)
				v.vars.name:setText(taskCfg.refuseBtnText)
			end
		end
	else
		self._layout.vars.dialogue:setText(data.sublineDialogue)
	end
end

function wnd_field_subline_task:onChooseTask(sender, isTake)
	local data = i3k_db_npc[self._npcId]
	local groupId = data.exchangeId[1]
	local taskCfg = i3k_db_subline_task[groupId][1]
	if isTake then
		if taskCfg.conditionType == 1 then--等级
			local value = 0
			if i3k_db_common.sublineTaskAdvanceShow > 0 then
				value = g_i3k_game_context:GetLevel() + 1
			else
				value = g_i3k_game_context:GetLevel()
			end
			if value < taskCfg.conditionValue then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1830, taskCfg.conditionValue))
				return
			end
		elseif taskCfg.conditionType == 2 then--战力
			if g_i3k_game_context:GetRolePower() < taskCfg.conditionValue then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1831))
				return
			end
		elseif taskCfg.conditionType == 3 then--完成主线任务
			if (g_i3k_game_context:getMainTaskIdAndVlaue() - 1) < taskCfg.conditionValue then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1831))
				return
			end
		elseif taskCfg.conditionType == 4 then--支线任务组Id
			if 0 < taskCfg.conditionValue then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1831))
				return
			end
		elseif taskCfg.conditionType == 5 then---飞升升级任务，手动接取
			local value = -65536
			local fs = g_i3k_game_context:getFeishengInfo()
			if taskCfg.arg1 == fs._level + 1 and fs._upgraing then
				value = taskCfg.conditionValue
			end
			if value < taskCfg.conditionValue then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1831))
				return
			end
		elseif taskCfg.conditionType == 6 then
			if g_i3k_game_context:GetLoginDays() < taskCfg.conditionValue then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1831))
				return
			end
		elseif taskCfg.conditionType == 7 then -- 五转之路  手动接取的任务
			if 0 < taskCfg.conditionValue then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1831))
				return
			end
		end
		if not (g_i3k_game_context:GetTransformBWtype() == taskCfg.bwType or taskCfg.bwType == 0) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1831))
			return
		end
		local callback = function ()
			local world = i3k_game_get_world()
			local npc = world:GetNPCEntityByID(self._npcId)
			if npc then
				g_i3k_ui_mgr:PopTextBubble(true, npc, taskCfg.getPopText)
			end
			g_i3k_ui_mgr:CloseUI(eUIID_FieldSublineTask)
		end
		i3k_sbean.branch_task_receive(groupId, true, callback)
	else
		local world = i3k_game_get_world()
		local npc = world:GetNPCEntityByID(self._npcId)
		if npc then
			g_i3k_ui_mgr:PopTextBubble(true, npc, taskCfg.refusePopText)
		end
		self:onCloseUI()
	end
end

function wnd_field_subline_task:onHide()
	
end

function wnd_create(layout)
	local wnd = wnd_field_subline_task.new()
	wnd:create(layout)
	return wnd
end