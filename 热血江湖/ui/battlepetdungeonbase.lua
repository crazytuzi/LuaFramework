module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_battlePetDungeon = i3k_class("wnd_battlePetDungeon", ui.wnd_base)
local TASKITEM = "ui/widgets/zdchongwushiliant"

function wnd_battlePetDungeon:ctor()
	
end

function wnd_battlePetDungeon:configure()
	local weight = self._layout.vars
	weight.gatherBt:onClick(self, self.onGatherDetailBt)
	weight.taskBt:onClick(self, self.onTaskDetailBt)
	weight.reward:onClick(self, self.onRewardBt)
	weight.event:onClick(self, self.onEventBt)
	weight.changeEquip:onClick(self, self.onChangeEquipBt)
	weight.tip:onClick(self, function() g_i3k_logic:OpenPetActivityTipUI() end)
end

function wnd_battlePetDungeon:refresh()
	self:refreshTaskText()
	self:refreshGatherText()
	self:refreshTaskScoll()
end

function wnd_battlePetDungeon:refreshTaskText()
	self._layout.vars.tasknum:setText(string.format("%s/%s", g_i3k_game_context:getPetDungeonTaskCount(), i3k_db_PetDungeonBase.taskCount))
end

function wnd_battlePetDungeon:refreshGatherText()
	self._layout.vars.gatherNum:setText(string.format("%s/%s", g_i3k_game_context:getPetDungeonGatherCount(), i3k_db_PetDungeonBase.gatherAllCount))
end

function wnd_battlePetDungeon:refreshTaskScoll()
	local info = g_i3k_game_context:getPetDungeonInfo() 
	local tasks = {}
	local scoll = self._layout.vars.taskscoll
	
	local fun = function(a, b)
		return -a.sort < -b.sort
	end
	
	if info then
		for _, v in pairs(info.tasks) do
			if v.state ~= 3 then
				if v.state == 1 then
					v.sort = 1000 
				elseif v.state == 2 then
					v.sort = 1000000000
				end
				
				v.sort = v.sort + v.takeTime			
				table.insert(tasks, v)	
			end
		end
	end
	
	table.sort(tasks, fun)
	
	local items = scoll:addChildWithCount(TASKITEM, 1, #tasks, true)
	
	for k, v in ipairs(items) do
		local weight = v.vars
		local taskItem = tasks[k]
		local cfg = i3k_db_PetDungeonTasks[taskItem.id]
		local desc = g_i3k_db.i3k_db_get_task_desc(cfg.type, cfg.arg1, cfg.arg2, taskItem.value, taskItem.value >= cfg.arg2)		
			
		if taskItem.state == 1 then
			weight.effect1:hide()
		elseif taskItem.state == 2 then
			weight.effect1:show()
		end
				
		weight.taskName:setText(cfg.name)
		weight.taskDesc:setText(desc)
		weight.time_label:hide()
		weight.taskDesc:setTag(taskItem.id)
		--i3k_log("lht" .. taskItem.id .. "------" .. taskItem.takeTime ..  "------" .. weight.taskDesc:getTag());
		weight.task_btn:onClick(self, self.onDoBt, {taskCfg = cfg, taskInfo = taskItem})
		g_i3k_logic:ChangePowerRepNpcTitleVisible(cfg.npcID, false)
	end
	
	self:refreshNpcTitle()
end

function wnd_battlePetDungeon:refreshNpcTitle()
	local info = g_i3k_game_context:getPetDungeonInfo()
	
	if info then
		local tasks = info.finishTasks or {}

		for k, _ in pairs(tasks) do 
			local cfg = i3k_db_PetDungeonTasks[k]
			
			if cfg then
				g_i3k_logic:ChangePowerRepNpcTitleVisible(cfg.npcID, false)
			end
		end
	end
end

function wnd_battlePetDungeon:onTaskDetailBt()
	if g_i3k_game_context:isCompleteAllPetDungeonTasks() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1492))
		return
	end
	
	g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonTaskDetail)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonTaskDetail)
end

function wnd_battlePetDungeon:onGatherDetailBt()
	g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonGatherDetail)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonGatherDetail)
end

function wnd_battlePetDungeon:onRewardBt()
	g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonrRewards)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonrRewards)
end

function wnd_battlePetDungeon:onEventBt()
	g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonrEvents)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonrEvents)
end

function wnd_battlePetDungeon:onChangeEquipBt()
	g_i3k_logic:OpenPetEquipUI(nil, false, true)
end

function wnd_battlePetDungeon:onDoBt(sender, info)
	local cfg = info.taskCfg
	local taskItem = info.taskInfo
	local mapCfg = i3k_db_PetDungeonMaps[cfg.mapID]
	
	if mapCfg and mapCfg.mapID ~= g_i3k_game_context:GetWorldMapID() then
		local index = g_i3k_game_context:getpetDungeonMapIndex(mapCfg.mapID)
		local cfg = i3k_db_PetDungeonMaps[index]
		
		if cfg then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1493, cfg.name))
		end
		
		return
	end
	
	if taskItem.state == 2 then
		local items = {}
	
		for k, v in ipairs(cfg.rewards) do
			local id = v.id
		
			if items[id] ~= nil then
				items[id] = items[id] + v.count
			else
				items[id] = v.count
			end
		end
	
		local isEnough = g_i3k_game_context:IsBagEnough(items)
		
		if not isEnough then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1494))
			return
		end
		
		i3k_sbean.submitPetDungeonTask(taskItem.id)
		return
	end
	
	g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_PETDUNGEON, cfg, cfg.arg1)
end

function wnd_battlePetDungeon:updateTaskItemSchedule(taskID, value)
	local scoll = self._layout.vars.taskscoll
	local child = scoll:getAllChildren()
	local item = nil
	
	for _, v in pairs(child) do
		local weight = v.vars.taskDesc
		
		if weight:getTag() == taskID then
			item = weight
		end
	end
	
	if item then
		local cfg = i3k_db_PetDungeonTasks[taskID]
		local desc = g_i3k_db.i3k_db_get_task_desc(cfg.type, cfg.arg1, cfg.arg2, value, value >= cfg.arg2)
		item:setText(desc)
	end
end

function wnd_create(layout)
	local wnd = wnd_battlePetDungeon.new();
		wnd:create(layout);
	return wnd;
end