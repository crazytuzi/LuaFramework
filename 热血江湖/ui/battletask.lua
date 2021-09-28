
module(..., package.seeall)
local require = require;
require("ui/map_set_funcs")
require "i3k_math"
local ui = require("ui/taskBase");
local BASE = ui.taskBase
-------------------------------------------------------
wnd_battleTask = i3k_class("wnd_battleTask", ui.taskBase)

local LAYER_RWLBT = "ui/widgets/rwlbt"
local LAYER_RWLBT2 = "ui/widgets/rwlbt2"
local LAYER_RWLBT3 = "ui/widgets/rwlbt3"
local LAYER_LIMIT = "ui/widgets/rwlbtxs"
local LAYER_RWLBTZLQJ = "ui/widgets/rwlbtzlqj"

local loopDesc = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二", "十三", "十四", "十五"}

--帮派共享任务剩余时间
local l_ScrollPercent = 0

function wnd_battleTask:ctor()
	self._SelectedBtn = nil
	self.isSearchPath = false
	self._faction_task_timer = nil
	self._scrollItems = {}
	self._countdown = {}

	self._timeCounter = 0
	self._taskGuideTime = 0
	self._taskGuideCo = nil
	self._wgs = {} 	--得到的任务的widget，废弃时要释放掉
end

function wnd_battleTask:configure()
	BASE.configure(self)
	BASE.setTabState(self, 1)
    local widget=self._layout.vars
    local task = {btn = widget.taskBtn, scroll = widget.task_scroll}
	self._taskAndMapTab = {task, map}
    self.task_scroll = self._layout.vars.task_scroll
end

function wnd_battleTask:refresh(state)
	g_i3k_game_context:InitTaskDataList()
	self:ShowTaskList(state)
	self:updateTaskInfo()
end

function wnd_battleTask:ShowTaskList(state)
	if state then
	 	self.task_scroll:hide()
	end
end

function wnd_battleTask:onHide()
	self:cancelTimer(true)
	self._scrollItems = {}
end

--注销计时器
function wnd_battleTask:cancelTimer(force)
	if self._faction_task_timer then
		if table.nums(self._countdown) == 0 or force then
			self._faction_task_timer:CancelTimer()
			self._faction_task_timer = nil
		end
	end
end
---------------------------------------

function wnd_battleTask:updateTaskInfo()
	self.isSearchPath = false
	self._scrollItems = {}
	self._countdown = {}
	self.task_scroll:removeAllChildren()
	
	local orderData = g_i3k_game_context:getTaskListOrderDate()
	for k,v in ipairs(orderData) do
		self:initTaskLayer(v.task)
	end
	self:initAwakenTask();
	self:initDragonTask()
	self:initLimitTask()
	l_ScrollPercent = l_ScrollPercent or 0
	self.task_scroll:jumpToListPercent(l_ScrollPercent)
end

function wnd_battleTask:updateTaskLayer(taskCat, node, time)
	self._scrollItems[taskCat] = node
	if taskCat == TASK_CATEGORY_MAIN then--主线
		self:updateMainTaskTag()

	elseif taskCat == TASK_CATEGORY_WEAPON then--神兵

	elseif TASK_CATEGORY_SECT == taskCat then --帮派
		if time then
			self:addTaskTimeDown(TASK_CATEGORY_SECT, time, node.vars.taskDesc2)
		end

	-- elseif taskCat >= 1000 then--支线TASK_CATEGORY_SUBLINE
	elseif g_i3k_db.i3k_db_check_subline_task_by_hash_id(taskCat) then--支线TASK_CATEGORY_SUBLINE
		-- local groupId = math.floor(taskCat/1000)
		local groupId = g_i3k_db.i3k_db_get_subline_task_real_id(taskCat)
		self:updateSubLineTaskTag(groupId)
	elseif g_i3k_db.i3k_db_check_power_rep_task_by_hash_id(taskCat) then
		self:updatePowerRepTaskTag(taskCat)
	elseif g_i3k_db.i3k_db_check_festival_task_by_hash_id(taskCat) then
		self:updateFestivalTaskTag(taskCat)
		if time then
			self:addTaskTimeDown(taskCat, time, node.vars.taskDesc2)
		end
	elseif TASK_CATEGORY_SECRETAREA == taskCat then --秘境

	elseif TASK_CATEGORY_ESCORT == taskCat then	--帮派运镖

	elseif i3k_get_MrgTaskCategory() == taskCat then --结婚系列任务TASK_CATEGORY_MRG_LOOP
		self:updateMrgTaskTag()
	elseif TASK_CATEGORY_STELA == taskCat then --太玄碑文任务
		self:updateStelaTask()
		if time then
			self:addTaskTimeDown(TASK_CATEGORY_STELA, time, node.vars.taskDesc2)
		end
	elseif TASK_CATEGORY_EPIC == taskCat then
		self:updateEpicTaskTag()
	elseif TASK_CATEGORY_AWAKEN == taskCat then
	elseif taskCat > 100 then
		if time then
			self:addTaskTimeDown(taskCat, time, node.vars.taskDesc2)
		end
	elseif TASK_CATEGORY_ADVENTURE == taskCat then
		self:updateAdventureTaskTag()
		if time then
			self:addTaskTimeDown(taskCat, time, node.vars.taskDesc2)
		end
	elseif TASK_CATEGORY_LIMIT == taskCat then
		if time then
			self:addTaskTimeDown(taskCat, time, node.vars.time_label)
		end
	elseif taskCat == TASK_CATEGORY_CHESS then
		self:updateChessTaskTag()
		if time then
			self:addTaskTimeDown(taskCat, time, node.vars.taskDesc2)
		end
	elseif taskCat == TASK_CATEGORY_JUBILEE then
		self:updateJubileeTaskTag(taskCat)
	elseif taskCat == TASK_CATEGORY_RING then
		self:updateFSRTag()
	elseif taskCat == TASK_CATEGORY_DETECTIVE then
		self:updateDetectiveTaskTag()
		if time then
			self:addTaskTimeDown(taskCat, time, node.vars.taskDesc2)
		end
	elseif taskCat == TASK_CATEGORY_SWORDSMAN then
		self:updateSwordsmanTaskTag()
	end
end

function wnd_battleTask:initTaskLayer(taskCat)

	if taskCat == TASK_CATEGORY_MAIN then--主线
		local id, value, state = g_i3k_game_context:getMainTaskIdAndVlaue()
		local mainTaskItem = self:createMainTaskItem()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, "updateFengce", id>=i3k_db_fengce.baseData.taskId+1)
		if mainTaskItem then
			self.task_scroll:addItem(mainTaskItem)
			self:updateTaskLayer(taskCat, mainTaskItem)
		end

	elseif taskCat == TASK_CATEGORY_WEAPON then--神兵
		local id,loop = g_i3k_game_context:getWeaponTaskIdAndLoopType()
		local value1,value2 = g_i3k_game_context:getWeaponTaskArgsCountAndArgs()
		local dayLoopCount = g_i3k_game_context:getWeaponDayLoopCount()
		local weaponTaskItem = self:createWeaponTaskItem(loop, id, value1, value2, dayLoopCount)
		if weaponTaskItem then
			self.task_scroll:addItem(weaponTaskItem)
			self:updateTaskLayer(taskCat, weaponTaskItem)
		end

	elseif TASK_CATEGORY_SECT == taskCat then --帮派
		local my_id = g_i3k_game_context:GetRoleId()
		local f_task = g_i3k_game_context:getFactionCurrentTask()
		local factionTaskItem, time = self:createFactionTaskItem(f_task.guid, f_task.taskID, f_task.value, f_task.roleID, f_task.receiveTime,my_id)
		if factionTaskItem then
			l_ScrollPercent = 0
			self.task_scroll:addItem(factionTaskItem)
			self:updateTaskLayer(taskCat, factionTaskItem, time)
		end

	-- elseif taskCat >= 1000 then--支线TASK_CATEGORY_SUBLINE
	-- 	local groupId = math.floor(taskCat/1000)
	elseif g_i3k_db.i3k_db_check_subline_task_by_hash_id(taskCat) then
		local groupId = g_i3k_db.i3k_db_get_subline_task_real_id(taskCat)
		local SubLineTaskItem = self:createSubLineTaskItem(groupId)
		if SubLineTaskItem then -- TODO 先注释掉，不然任务太多了
			self.task_scroll:addItem(SubLineTaskItem)
			self:updateTaskLayer(taskCat, SubLineTaskItem)
		end

	elseif TASK_CATEGORY_SECRETAREA == taskCat then --秘境
		local secretareaTaskItem = self:createSecretareaTaskItem( )
		if secretareaTaskItem then
			l_ScrollPercent = 0
			self.task_scroll:addItem(secretareaTaskItem)
			self:updateTaskLayer(taskCat, secretareaTaskItem)
		end

	elseif TASK_CATEGORY_ESCORT == taskCat then	--帮派运镖
		local EscortItem = self:createFactionEscort()
		if EscortItem then
			l_ScrollPercent = 0
			self.task_scroll:addItem(EscortItem)
		end
	elseif i3k_get_MrgTaskCategory() == taskCat then --结婚系列任务TASK_CATEGORY_MRG_LOOP
		local mrg_item = self:createMarriageTaskItem()
		if mrg_item then
			self.task_scroll:addItem(mrg_item)
			self:updateTaskLayer(taskCat, mrg_item)
		end
	elseif TASK_CATEGORY_STELA == taskCat then --太玄碑文任务
		local stl_item, time = self:createStelaTaskItem()
		if stl_item then
			self.task_scroll:addItem(stl_item)
			self:updateTaskLayer(taskCat, stl_item, time)
		end
	elseif TASK_CATEGORY_EPIC == taskCat then
		local mainTaskItem = self:createEpicTaskItem()
		if mainTaskItem then
			self.task_scroll:addItem(mainTaskItem)
			self:updateTaskLayer(taskCat, mainTaskItem)
		end
	elseif TASK_CATEGORY_ADVENTURE == taskCat then
		local mainTaskItem, time = self:createAdventureTaskItem()
		if mainTaskItem then
			self.task_scroll:addItem(mainTaskItem)
			self:updateTaskLayer(taskCat, mainTaskItem, time)
		end
	elseif TASK_CATEGORY_FCBS == taskCat then
		local mainTaskItem = self:createFCBSTaskItem()
		if mainTaskItem then
			self.task_scroll:addItem(mainTaskItem)
			self:updateTaskLayer(taskCat, mainTaskItem, time)
		end
	elseif TASK_CATEGORY_CHESS == taskCat then
		local chessTask, time = self:createChessTaskItem()
		if chessTask then
			self.task_scroll:addItem(chessTask)
			self:updateTaskLayer(taskCat, chessTask, time)
		end
	--[[elseif TASK_CATEGORY_POWER_REP == taskCat then

		local taskItem = self:createPowerRepTaskItem()--]]
	elseif g_i3k_db.i3k_db_check_power_rep_task_by_hash_id(taskCat) then -- 势力声望任务
		local taskItem = self:createPowerRepTaskItem(taskCat)
		if taskItem then
			self.task_scroll:addItem(taskItem)
			self:updateTaskLayer(taskCat, taskItem)
		end
	elseif g_i3k_db.i3k_db_check_festival_task_by_hash_id(taskCat) then
		local festivalTask, time = self:createFestivalTaskItem(taskCat)
		if festivalTask then
			self.task_scroll:addItem(festivalTask)
			self:updateTaskLayer(taskCat, festivalTask, time)
		end
	elseif taskCat == TASK_CATEGORY_JUBILEE then
		local jubileeTask = self:createJubileeTaskItem(taskCat)
		if jubileeTask then
			self.task_scroll:addItem(jubileeTask)
			self:updateTaskLayer(taskCat, jubileeTask)
		end
	elseif taskCat == TASK_CATEGORY_RING then
		local wg = self:createFSRItem()
		self.task_scroll:addItem(wg)
		self:updateTaskLayer(taskCat, wg)
	elseif taskCat == TASK_CATEGORY_DETECTIVE then
		local taskItem, time = self:createDetectiveItem()
		if taskItem then
			self.task_scroll:addItem(taskItem)
			self:updateTaskLayer(taskCat, taskItem, time)
		end
	elseif taskCat == TASK_CATEGORY_SWORDSMAN then
		local taskItem = self:createSwordsmanTask()
		if taskItem then
			self.task_scroll:addItem(taskItem)
			self:updateTaskLayer(taskCat, taskItem)
		end
	elseif taskCat == TASK_CATEGORY_GLOBALWORLD then
		local taskItem = self:createGlobalWorldTask()
		if taskItem then
			self.task_scroll:addItem(taskItem)
			self:updateTaskLayer(taskCat, taskItem)
		end
	end
end
function wnd_battleTask:createFSRItem()
	local wg = require("ui/widgets/rwlbt2")()
	wg.vars.task_btn:onClick(self, self.doFSRTask)
	return wg
end
function wnd_battleTask:updateFSRTag()
	local layer = self._scrollItems[TASK_CATEGORY_RING]
	if layer then
		local fs = g_i3k_game_context:getFeishengInfo()
		local info = g_i3k_game_context:getFSRTaskInfo()
		local cfg = i3k_db_ring_mission[info.id]
		local desc = self:getCommonTaskDesc(cfg, info.value, info.state, self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, info.value))
		layer.vars.taskName:setText(cfg.name)
		layer.vars.taskDesc:setText(desc)
		layer.vars.taskDesc2:setText(i3k_get_string(1766, fs._dailyFinished, i3k_db_role_flying[fs._level].ringMissionNum))
	end
end
function wnd_battleTask:doFSRTask()
	local info = g_i3k_game_context:getFSRTaskInfo()
	local cfg = i3k_db_ring_mission[info.id]
	l_ScrollPercent = self.task_scroll:getListPercent()
	local rwds = g_i3k_db.i3k_db_get_FSR_rewards(info.id)
	if self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, info.value) then
		if g_i3k_game_context:checkBagCanAddCell(#rwds - 1, true) then
			i3k_sbean.finishRingMission(info.id)
		end
	else
		local QFTinfo = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_RING)
		local needItemNum = QFTinfo.needItemCount
		local needItemName = g_i3k_db.i3k_db_get_common_item_name(QFTinfo.needItemId)
		local currActivity = g_i3k_game_context:GetScheduleInfo().activity
		if currActivity >= QFTinfo.needActivity then
			local msg = i3k_get_string(1761, QFTinfo.needActivity, needItemNum)
			g_i3k_ui_mgr:OpenAndRefresh(eUIID_FeishengQuickFinish, msg, needItemNum, function(ok)
				if ok then
					if g_i3k_game_context:GetCommonItemCanUseCount(QFTinfo.needItemId) < needItemNum then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(415))
					else
						if g_i3k_game_context:checkBagCanAddCell(#rwds - 1, true) then
							i3k_sbean.quickFinishRingMission(info.id)
						end
					end
				else
					g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_RING, cfg)
				end
			end)
		else
			g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_RING, cfg)
		end
	end
end
----------宠物觉醒
function wnd_battleTask:initAwakenTask()
	self:removeTaskItem(TASK_CATEGORY_AWAKEN)
	local taskItem = self:createPetAwakenTaskItem()
	self:updateItemPos(TASK_CATEGORY_AWAKEN, taskItem)
end

function wnd_battleTask:updateAwakenTaxt(id)
	local layer = self._scrollItems[TASK_CATEGORY_AWAKEN]
	if layer then
		local state = g_i3k_game_context:getPetWakenTaskState(id);
		if state == g_TaskState2 then
			layer.vars.taskDesc:setText(i3k_get_string(16826));
			layer.vars.effect1:show()
		else
			layer.vars.taskDesc:setText(i3k_get_string(16841))
			layer.vars.effect1:hide()
		end
	end
end

function wnd_battleTask:removeAwakenTask()
	local index = self:removeTaskItem(TASK_CATEGORY_AWAKEN)
	self:updateMainItemPos(index)
end

function wnd_battleTask:createPetAwakenTaskItem()
	local pid = g_i3k_game_context:getPetWakening();
	if pid then
		local task = g_i3k_game_context:getPetWakenTask(pid)
		if task then
			local _layer = require(LAYER_RWLBT)()
			local vars = _layer.vars
			vars.time_label:hide()
			local name = string.format("%s%s",i3k_get_string(16840),task.taskName)
			vars.taskName:setText(name)
			local state = g_i3k_game_context:getPetWakenTaskState(pid);
			if state == g_TaskState2 then
				vars.taskDesc:setText(i3k_get_string(16826));
				vars.effect1:show()
			else
				vars.taskDesc:setText(i3k_get_string(16841))
				vars.effect1:hide()
			end
			local arg = {taskType = task.taskType, pid = pid}
			vars.task_btn:onClick(self, self.OnAwakenTaskBtn, arg)
			vars.task_btn:setTag(TASK_CATEGORY_AWAKEN)
			return _layer
		end
	end
end

function wnd_battleTask:OnAwakenTaskBtn(sender, arg)
	if arg and arg.taskType then
		if arg.taskType == g_TASK_KILL then
			g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenTask1)
			g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenTask1,arg.pid)
		elseif arg.taskType == g_TASK_PASS_FUBEN then
			g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenTask2)
			g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenTask2,arg.pid)
		elseif arg.taskType == g_TASK_SUBMIT_ITEM then
			g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenTask3)
			g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenTask3,arg.pid)
		end
	end
end

---------------------------------主线
function wnd_battleTask:createMainTaskItem()
	local _layer = require(LAYER_RWLBT)()
	local task_btn = _layer.vars.task_btn
	local taskName = _layer.vars.taskName
	--local taskDesc = _layer.vars.taskDesc
	local time_label = _layer.vars.time_label
	local effect1 = _layer.vars.effect1
	effect1:hide()
	time_label:hide()
	local id, value, state = g_i3k_game_context:getMainTaskIdAndVlaue()
	if not id or id == 0 then
		return
	end

	local cfg = g_i3k_db.i3k_db_get_main_task_cfg(id)

	local name = string.format("%s%s",i3k_get_string(33),cfg.name)
	taskName:setText(name)
	--taskDesc:setText(desc)
	task_btn:onClick(self, self.DoMainTask, {type = TASK_CATEGORY_MAIN, id = id, cfg = cfg})
	task_btn:setTag(TASK_CATEGORY_MAIN)

	return _layer
end

function wnd_battleTask:doGetTask(args)
	local cfg = args.cfg

	if g_i3k_game_context:CheckTransformationTaskState(cfg.effectIdList) and not g_i3k_game_context:IsInMetamorphosisMode() then
		g_i3k_ui_mgr:PopupTipMessage("请先完成当前变身任务")
		return
	end
	if cfg.getTaskNpcID == 0 then
		g_i3k_game_context:OpenGetTaskDialogue(cfg, args.type)
	else
		self:transportToNpc(cfg.getTaskNpcID, args.type)
	end
end

function wnd_battleTask:getTaskIsfinish(taskType, arg1, arg2, value)
	local is_ok = g_i3k_game_context:IsTaskFinished(taskType, arg1, arg2, value)
	return g_i3k_game_context:TaskItemIsEnough(taskType, is_ok, arg1, arg2)
end

function wnd_battleTask:doTask(args, state, value)
	l_ScrollPercent = self.task_scroll:getListPercent()
	self._SelectedBtn = args.type

	local cfg = args.cfg
	if state == 0 then
		return self:doGetTask(args)
	end

	if state >= 1 and self:getTaskIsfinish(cfg.type,cfg.arg1, cfg.arg2, value) then
		return self:doFinishTask(args)
	end

	if cfg.keyNodeID and cfg.keyNodeID == 1 then
		--走特殊逻辑
		return self:doSpecialWay()
	end

	self:gotoTaskPosition(args)
end

function wnd_battleTask:DoMainTask(sender, args)
	i3k_game_set_click_pos()
	local _, value, state = g_i3k_game_context:getMainTaskIdAndVlaue()
	self:doTask(args, state, value)
end

function wnd_battleTask:getCommonTaskDesc(cfg, value, state, isFinish)
	local desc = g_i3k_db.i3k_db_get_task_specialized_desc(cfg,isFinish)
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

function wnd_battleTask:updateMainTaskTag(isAuto, category)
	local _layer = self._scrollItems[TASK_CATEGORY_MAIN].vars
	local id, value, state = g_i3k_game_context:getMainTaskIdAndVlaue()
	local cfg = g_i3k_db.i3k_db_get_main_task_cfg(id)
	local taskType = cfg.type

	local is_ok = self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, value)

	_layer.taskDesc:setText(self:getCommonTaskDesc(cfg, value, state, is_ok))

	if state >= 1 and is_ok then
		local effect1 = _layer.effect1
		if effect1 then
			effect1:show()
		end
		self.isSearchPath = isAuto
		self:finishMainTask(cfg)
		return
	end

	if isAuto then
		g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_MAIN, cfg)
	end
end

function wnd_battleTask:updateMainTask(id, value, isok)
	self.isSearchPath = true

	local layer = self._scrollItems[TASK_CATEGORY_MAIN]
	if layer and isok ~= nil then
		local cfg = g_i3k_db.i3k_db_get_main_task_cfg(id)
		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, value, 1, isok))
		if isok then
			if cfg.type ~= g_TASK_REACH_LEVEL then
				layer.vars.effect1:show()
	  			self:finishMainTask(cfg)
			else
				self:removeTaskItem(TASK_CATEGORY_MAIN)
				self:updateItemPos(TASK_CATEGORY_MAIN, self:createMainTaskItem())
			end
		end
	else
		local index = self:removeTaskItem(TASK_CATEGORY_MAIN)
		local mainTaskItem = self:createMainTaskItem()
		self:updateItemPos(TASK_CATEGORY_MAIN,mainTaskItem)
	end

	if id==i3k_db_fengce.baseData.taskId+1 and not g_i3k_game_context:getIsUpdateFengce() then
		g_i3k_game_context:setIsUpdateFengce(true)
		local hero = i3k_game_get_player_hero()
		--g_i3k_game_context:setFengceRedCache(false, true, hero._lvl>=i3k_db_fengce.fengcePackage[1].level, true, i3k_db_fengce.sprint.startTime==1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, "updateFengce", true)
	end
end

function wnd_battleTask:doSpecialWay()
	g_i3k_ui_mgr:OpenUI(eUIID_MainTask_SpecialUI)
	g_i3k_ui_mgr:RefreshUI(eUIID_MainTask_SpecialUI)
end

function wnd_battleTask:finishMainTask(cfg)
	if self._SelectedBtn == TASK_CATEGORY_MAIN and self.isSearchPath then
		self:finishTask(cfg, TASK_CATEGORY_MAIN)
	end
end

function wnd_battleTask:joyTodoMainTask()
	if not self.task_scroll:isVisible() then
		return
	end
	local listItem = self._scrollItems[TASK_CATEGORY_MAIN]
	if listItem then
		listItem.vars.task_btn:sendClick()
	end
end

-------------------------------------------支线任务
function wnd_battleTask:doGetSubLineTask(args)
	local cfg = args.cfg

	if g_i3k_game_context:CheckTransformationTaskState(cfg.effectIdList) and not g_i3k_game_context:IsInMetamorphosisMode() then
		g_i3k_ui_mgr:PopupTipMessage("请先完成当前变身任务")
		return
	end
	if cfg.getTaskNpcID == 0 then
		g_i3k_game_context:GetSubLineTaskDialogue(cfg.taskgroupid, cfg.id)
	else
		self:transportToNpc(cfg.getTaskNpcID, TASK_CATEGORY_SUBLINE, cfg.taskgroupid)
	end
end

function wnd_battleTask:doSubTask(sender, args)
	l_ScrollPercent = self.task_scroll:getListPercent()
	self._SelectedBtn = args.type

	local d = g_i3k_game_context:getSubLineIdAndValueBytype(args.otherId)
	local cfg = args.cfg

	if cfg.conditionType == 1 and g_i3k_game_context:GetLevel() < cfg.conditionValue then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16861,cfg.conditionValue))
	end

	if d.state == 0 then
		return self:doGetSubLineTask(args)
	end

	if d.state >= 1 and self:getTaskIsfinish(cfg.type,cfg.arg1, cfg.arg2, d.value) then
		return self:doFinishSubLineTask(args)
	end

	self:gotoTaskPosition(args)
end

function wnd_battleTask:createSubLineTaskItem(groupId)
	local data = g_i3k_game_context:getSubLineIdAndValueBytype(groupId)
	if data == nil or data.id == 0 then
		return;
	end
	local id = data.id
	local value = data.value
	local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(groupId, id)
	if data.state == 0 and cfg.isHide == 1 then
		return
	end
	local _layer = require(LAYER_RWLBT)()
	local task_btn = _layer.vars.task_btn
	local taskName = _layer.vars.taskName
	local time_label = _layer.vars.time_label
	local effect1 = _layer.vars.effect1

	local btnIndex = g_i3k_db.i3k_db_get_subline_task_hash_id(groupId)

	effect1:hide()
	time_label:hide()


	local name = string.format("%s%s",cfg.prename,cfg.name)
	taskName:setText(name)
	task_btn:setTag(btnIndex)
	task_btn:onClick(self, self.doSubTask, {type = btnIndex ,id = data.id, otherId = groupId, cfg = cfg})

	return _layer
end

function wnd_battleTask:updateSubLineTaskTag(groupId, isAuto)
	local subline_data = g_i3k_game_context:getSubLineIdAndValueBytype(groupId)
	local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(groupId, subline_data.id)
	-- local btnIndex = groupId*1000
	local btnIndex = g_i3k_db.i3k_db_get_subline_task_hash_id(groupId)
	local _layer = self._scrollItems[btnIndex].vars

	local is_ok = self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, subline_data.value)
	if cfg.conditionType == 1 and g_i3k_game_context:GetLevel() < cfg.conditionValue then
		_layer.taskDesc:setText(i3k_get_string(16861,cfg.conditionValue))
	else
		_layer.taskDesc:setText(self:getCommonTaskDesc(cfg, subline_data.value, subline_data.state, is_ok))
	end

	if subline_data.state >= 1 and is_ok then
		self.isSearchPath = isAuto
		self:finishSubLineTask(groupId, subline_data.id, cfg)
		return
	end

	if isAuto then
		g_i3k_game_context:GoingToDoTask(btnIndex, cfg, cfg.taskgroupid)
	end
end

function wnd_battleTask:doFinishSubLineTask(args)
	self.isSearchPath = true
	self:finishSubLineTask(args.otherId, args.id, args.cfg)
end

function wnd_battleTask:finishSubLineTask(groupId, taskid, cfg)
	-- if self._SelectedBtn == groupId*1000 and self.isSearchPath then
	if self._SelectedBtn == g_i3k_db.i3k_db_get_subline_task_hash_id(groupId) and self.isSearchPath then
		if cfg.finishTaskNpcID == 0 then
			g_i3k_game_context:FinishSubLineTaskDialogue(groupId,taskid,g_i3k_game_context:isBagEnoughSubLineTaskAward(groupId,taskid),g_i3k_game_context:getSublineTaskAward(groupId,taskid))
		else
			if taskType ~= g_TASK_REACH_LEVEL then
				self:transportToNpc(cfg.finishTaskNpcID,TASK_CATEGORY_SUBLINE,groupId)
			end
		end
	end
end

--更新支线任务
function wnd_battleTask:updateSublineTask(groupId, taskId, isok)
	self.isSearchPath = true
	-- local tag = groupId*1000
	local tag = g_i3k_db.i3k_db_get_subline_task_hash_id(groupId)
	local layer = self._scrollItems[tag]
	if layer and isok ~= nil then
		local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(groupId,taskId)
		local data = g_i3k_game_context:getSubLineIdAndValueBytype(groupId)
		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, data.value, 1, isok))

		if isok then
			if cfg.type == g_TASK_USE_ITEM and cfg.arg4 == 0 and data.value == 0 then
				self.isSearchPath = false
			end
			self:finishSubLineTask(groupId, taskId, cfg)
		end
	else
		local index = self:removeTaskItem(tag)
		local SubLineTaskItem = self:createSubLineTaskItem(groupId)
		self:updateItemPos(tag,SubLineTaskItem)
	end
end

function wnd_battleTask:removeSubTaskItem(groupId,taskId)
	-- local tag = groupId*1000
	local tag = g_i3k_db.i3k_db_get_subline_task_hash_id(groupId)
	local index = self:removeTaskItem(tag)
	self:updateMainItemPos(index)
	l_ScrollPercent = 0
end

---------------------------------------------太玄碑文
function wnd_battleTask:createStelaTaskItem()
	local endTime = i3k_db_steleAct.cfg.openTime + i3k_db_steleAct.cfg.duration - i3k_game_get_time()%86400
	if endTime <= 0 then
		return
	end
	local data = g_i3k_game_context:getStelaActivityData()
	if data.allFinish == 1 or data.index == 0 or data.canContinue == 0 then
		return
	end

	local _layer = require(LAYER_RWLBT2)()

	local taskCat = TASK_CATEGORY_STELA
	_layer.vars.task_btn:setTag(taskCat)

	return _layer, endTime
end

function wnd_battleTask:updateStelaTask()
	local layer = self._scrollItems[TASK_CATEGORY_STELA]

	local stlData = g_i3k_game_context:getStelaActivityData()
	local stlCfg = g_i3k_game_context:getStelaActivityDB()
	if layer and stlCfg then
		local mineCfg = i3k_db_resourcepoint[stlCfg.mineId]
		local vars = layer.vars
		vars.taskName:setText("<c=FFF0FF40>["..i3k_db_dungeon_base[stlCfg.mapId].desc .."]</c>"..mineCfg.name)
		vars.task_btn:onClick(self, self.findStalePath, stlCfg)
		vars.taskDesc:setText("已收集拓片:"..stlData.card)
	end
end

function wnd_battleTask:insertStelaItem()
	local index = self:removeTaskItem(TASK_CATEGORY_STELA)
	local mainTaskItem, time = self:createStelaTaskItem()
	self:updateItemPos(TASK_CATEGORY_STELA,mainTaskItem, time)
end

function wnd_battleTask:updateStelaCard(card)
	local layer = self._scrollItems[11]
	if layer then
		layer.vars.taskDesc:setText("已收集拓片:"..card)
	end
end

function wnd_battleTask:findStalePath(sender, args)
	local func = function()
		g_i3k_game_context:TaskCollect(args.mineId, args.pos)
	end
	g_i3k_game_context:SeachPathWithMap(args.mapId, args.pos,nil,nil,nil,nil,nil,func)
end

function wnd_battleTask:removeStelaTaskItem()
	local index = self:removeTaskItem(TASK_CATEGORY_STELA)
	self:updateMainItemPos(index)
end

------------------------------------------姻缘任务
function wnd_battleTask:createMarriageOpenTaskItem()

	local _layer = require(LAYER_RWLBT)()
	local task_btn = _layer.vars.task_btn
	local taskName = _layer.vars.taskName
	--local taskDesc = _layer.vars.taskDesc
	local time_label = _layer.vars.time_label
	local effect1 = _layer.vars.effect1
	effect1:hide()
	time_label:hide()

	local data = g_i3k_game_context:GetMarriageTaskData()
	local cfg = g_i3k_db.i3k_db_marry_task(data.id,data.groupID)
	local name = "<c=FFF0FF40>[姻缘]</c>开启任务"

	taskName:setText(name)
	_layer.vars.taskDesc:setText("<c=hrgreen>去找姻缘童子</c>")
	_layer.vars.task_btn:onClick(self, self.GotoOpenMrgTaskNpc)
	local taskCat = i3k_get_MrgTaskCategory()
	task_btn:setTag(taskCat)
	return _layer
end

function wnd_battleTask:GotoOpenMrgTaskNpc(sender)
	g_i3k_game_context:GotoOpenMrgTaskNpc()
end

function wnd_battleTask:DoMrgTask(send, args)
	local d = g_i3k_game_context:GetMarriageTaskData()
	self:doTask(args, d.state, d.value)
end

function wnd_battleTask:createMarriageTaskItem()
	local data = g_i3k_game_context:GetMarriageTaskData()
	if g_i3k_game_context:getMarryRoleId() <= 0 then
		return
	end
	if data.open <= 0 then
		return self:createMarriageOpenTaskItem()
	end

	if data.id <= 0 then
		return
	end

	local _layer = require(LAYER_RWLBT)()
	local task_btn = _layer.vars.task_btn
	local taskName = _layer.vars.taskName
	--local taskDesc = _layer.vars.taskDesc
	local time_label = _layer.vars.time_label
	local effect1 = _layer.vars.effect1
	effect1:hide()
	time_label:hide()

	local data = g_i3k_game_context:GetMarriageTaskData()
	local cfg = g_i3k_db.i3k_db_marry_task(data.id,data.groupID)
	local name =""
	if data.groupID and data.groupID == 0 then
		local totalCount= i3k_db_marryTaskCfg.loopTaskCnt
		local count = g_i3k_game_context:getMrgTaskCount()
		local curCount = totalCount - count 
		if totalCount - count < 0 then
			curCount = 0
		end
		name = string.format("<c=FFF0FF40>[姻缘]</c>%s%s",string.format("(%s/%s)", curCount, totalCount), cfg.name)
	else
	name = string.format("<c=FFF0FF40>[姻缘]</c>%s",cfg.name)
	end
	taskName:setText(name)
	--taskDesc:setText(desc)
	local taskCat = i3k_get_MrgTaskCategory()
	task_btn:setTag(taskCat)
	task_btn:onClick(self, self.DoMrgTask, {type = taskCat, id = data.id, otherId = data.groupID, cfg = cfg})
	return _layer
end

function wnd_battleTask:updateMrgTaskTag(isAuto)
	local taskCat = i3k_get_MrgTaskCategory()
	if not self._scrollItems[taskCat] then
		return
	end
	local _layer = self._scrollItems[taskCat].vars
	local data = g_i3k_game_context:GetMarriageTaskData()
	if data.open == 0 then
		return
	end

	local cfg = g_i3k_db.i3k_db_marry_task(data.id,data.groupID)
	local is_ok = self:getTaskIsfinish(cfg.type,cfg.arg1, cfg.arg2, data.value)
	_layer.taskDesc:setText(self:getCommonTaskDesc(cfg, data.value, data.state, is_ok))
	local totalCount= i3k_db_marryTaskCfg.loopTaskCnt
	local count = g_i3k_game_context:getMrgTaskCount()
	if data.groupID == 0 then
		local curCount = totalCount - count 
		if totalCount - count < 0 then
			curCount = 0
		end
		_layer.taskName:setText(string.format("<c=FFF0FF40>[姻缘]</c>%s%s",string.format("(%s/%s)", curCount, totalCount), cfg.name))
	end
	if data.state == 0 then
		if isAuto then
			self:doGetTask({type = taskCat, cfg = cfg})
		end
		return
	end

	if data.state >= 1 and is_ok then
		local effect1 = _layer.effect1
		if effect1 then
			effect1:show()
		end
		self.isSearchPath = isAuto
		self:finishMrgTask(cfg)
		return
	end

	if isAuto then
		g_i3k_game_context:GoingToDoTask(taskCat,cfg, data.groupID)
	end
end

function wnd_battleTask:updateMrgTask(id, groupID,value, isok)
	self.isSearchPath = true
	local taskCat = i3k_get_MrgTaskCategory()
	local layer = self._scrollItems[taskCat]
	if layer and isok ~= nil then
		local cfg = g_i3k_db.i3k_db_marry_task(id,groupID)
		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, value, 1, isok))
		if isok then
			layer.vars.effect1:show()
	  		self:finishMrgTask(cfg,taskCat)
		end
	else
		local index = self:removeTaskItem(taskCat)
		local mainTaskItem = self:createMarriageTaskItem()
		self:updateItemPos(taskCat,mainTaskItem)
	end
end

function wnd_battleTask:finishMrgTask(cfg)
	--self._SelectedBtn == i3k_get_MrgTaskCategory() and
	if self.isSearchPath then
		self:finishTask(cfg, i3k_get_MrgTaskCategory())
	end
end

function wnd_battleTask:removeMrgTask()
	local index = self:removeTaskItem(i3k_get_MrgTaskCategory())
	self:updateMainItemPos(index)
end

function wnd_battleTask:doFinishTask(args)
	self:finishTask(args.cfg, args.type)
end

function wnd_battleTask:finishTask(cfg, category)
	if category == TASK_CATEGORY_MAIN then
		if cfg.nextid == 0 and g_i3k_game_context:GetTransformBWtype() == 0 then
			return g_i3k_ui_mgr:PopupTipMessage("完成二转任务才能领取奖励")
		end
	end
	local npcID = cfg.finishTaskNpcID
	if npcID == 0 then
		g_i3k_game_context:OpenFinishTaskDialogue(cfg, category)
	else
		self:transportToNpc(npcID,category)
	end
end

-------------------------------------------史诗
function wnd_battleTask:createEpicTaskItem()
	local data = g_i3k_game_context:getCurrEpicTaskData()
	if data.id == 0 then
		return
	end

	local _layer = require(LAYER_RWLBT)()
	local vars = _layer.vars
	vars.time_label:hide()
	vars.effect1:hide()

	local cfg = g_i3k_db.i3k_db_epic_task_cfg(data.seriesID, data.groupID, data.id)
	local name = i3k_get_string(1052, i3k_db_epic_cfg[data.seriesID].titleName[data.groupID],cfg.name)
	_layer.vars.taskName:setText(name)

	vars.task_btn:setTag(TASK_CATEGORY_EPIC)
	vars.task_btn:onClick(self, self.doEpicTask)
	return _layer
end
function wnd_battleTask:doEpicTask(sender)
	local data = g_i3k_game_context:getCurrEpicTaskData()
	local args = {type = TASK_CATEGORY_EPIC, cfg = g_i3k_db.i3k_db_epic_task_cfg(data.seriesID, data.groupID, data.id)}
	self:doTask(args, data.state, data.value)
end

function wnd_battleTask:updateEpicTaskTag(isAuto)
	local _layer = self._scrollItems[TASK_CATEGORY_EPIC].vars
	local data = g_i3k_game_context:getCurrEpicTaskData()
	local cfg = g_i3k_db.i3k_db_epic_task_cfg(data.seriesID, data.groupID, data.id)

	local is_ok = self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, data.value)
	_layer.taskDesc:setText(self:getCommonTaskDesc(cfg, data.value, data.state, is_ok))

	if data.state >= 1 and is_ok then
		self.isSearchPath = isAuto
		self:finishEpicTask(cfg)
		return
	end

	if isAuto then
		g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_EPIC, cfg)
	end
end

function wnd_battleTask:updateEpicTask(isok)
	self.isSearchPath = true

	local layer = self._scrollItems[TASK_CATEGORY_EPIC]
	if layer and isok ~= nil then
		local data = g_i3k_game_context:getCurrEpicTaskData()
		local cfg = g_i3k_db.i3k_db_epic_task_cfg(data.seriesID, data.groupID, data.id)
		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, data.value, 1, isok))
		if isok then
	  		self:finishEpicTask(cfg)
		end
	else
		local index = self:removeTaskItem(TASK_CATEGORY_EPIC)
		local mainTaskItem = self:createEpicTaskItem()
		self:updateItemPos(TASK_CATEGORY_EPIC,mainTaskItem)
	end
end

function wnd_battleTask:finishEpicTask(cfg)
	if self._SelectedBtn == TASK_CATEGORY_EPIC and self.isSearchPath then
		self:finishTask(cfg, TASK_CATEGORY_EPIC)
	end
end

--------------------------奇遇
function wnd_battleTask:createAdventureTaskItem()
	local d_advt = g_i3k_game_context:getAdventure()

	if d_advt.trigID == 0 or
		(d_advt.trigEndTime ~= 0 and i3k_game_get_time() > d_advt.trigEndTime) then
		return
	end

	local data = d_advt.task
	local taskId = data.id
	local d_finished = d_advt.finished[d_advt.trigID]
	local _layer = nil
	local endTime = nil
	local cfg = nil
	if taskId <= 0 and not d_finished then
		_layer = require(LAYER_RWLBT2)()
		endTime = d_advt.trigEndTime - i3k_game_get_time()
		cfg = i3k_db_adventure.head[d_advt.trigID]
	elseif taskId > 0 then
		_layer = require(LAYER_RWLBT)()
		_layer.vars.effect1:show()
		_layer.vars.time_label:hide()
		cfg = i3k_db_adventure.tasks[taskId]
	end

	if _layer then
		local vars = _layer.vars
		_layer.vars.taskName:setText(i3k_get_string(16958)..cfg.name)

		vars.task_btn:setTag(TASK_CATEGORY_ADVENTURE)
		vars.task_btn:onClick(self, self.doAdventureTask)
	end
	return _layer, endTime
end

function wnd_battleTask:doAdventureTask(sender)
	local data = g_i3k_game_context:getAdventureTask()
	if data.id <= 0 then
		local d_advt = g_i3k_game_context:getAdventure()
		local head = i3k_db_adventure.head[d_advt.trigID]
		g_i3k_ui_mgr:OpenUI(head.uiId)
		g_i3k_ui_mgr:RefreshUI(head.uiId, d_advt.trigID, head.force)
	else
		local cfg = i3k_db_adventure.tasks[data.id]
		local args = {type = TASK_CATEGORY_ADVENTURE, cfg = cfg}
		self:doTask(args, data.state, data.value)
	end
end

function wnd_battleTask:updateAdventureTaskTag(isAuto)
	local _layer = self._scrollItems[TASK_CATEGORY_ADVENTURE].vars
	if _layer.effect1 then
		_layer.effect1:show()
	end
	local data = g_i3k_game_context:getAdventureTask()
	if data.id <= 0 then
		_layer.taskDesc:setText("点击查看")
		return
	end
	local cfg = i3k_db_adventure.tasks[data.id]
	local is_ok = self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, data.value)
	_layer.taskDesc:setText(self:getCommonTaskDesc(cfg, data.value, data.state, is_ok))
	if data.state >= 1 and is_ok then
		self.isSearchPath = isAuto
		self:finishAdventureTask(cfg, data.id)
		return
	end
	if isAuto then
		g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_ADVENTURE, cfg)
	end
end

function wnd_battleTask:updateAdventureTask(isok)
	self.isSearchPath = true

	local layer = self._scrollItems[TASK_CATEGORY_ADVENTURE]
	if layer and isok ~= nil then
		local data = g_i3k_game_context:getAdventureTask()
		local cfg = i3k_db_adventure.tasks[data.id]
		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, data.value, 1, isok))
		if isok then
	  		self:finishAdventureTask(cfg, data.id)
		end
	else
		local index = self:removeTaskItem(TASK_CATEGORY_ADVENTURE)
		local mainTaskItem, time = self:createAdventureTaskItem()
		self:updateItemPos(TASK_CATEGORY_ADVENTURE,mainTaskItem,time)
	end
end

function wnd_battleTask:finishAdventureTask(cfg, taskId)
	if self._SelectedBtn == TASK_CATEGORY_ADVENTURE and self.isSearchPath then
		if i3k_db_adventure.circuit[taskId].isChoose > 0 then
			g_i3k_ui_mgr:OpenUI(i3k_db_adventure.choose[taskId].uiId)
			g_i3k_ui_mgr:RefreshUI(i3k_db_adventure.choose[taskId].uiId)
		else
			self:finishTask(cfg, TASK_CATEGORY_ADVENTURE)
		end
	end
end

--------------------------商路
function wnd_battleTask:createFCBSTaskItem()
	local data = g_i3k_game_context:getFactionBusinessTask()
	if data.id == 0 then
		return
	end
	local _layer = require(LAYER_RWLBT)()
	local vars = _layer.vars

	vars.effect1:hide()
	vars.time_label:hide()

	local cfg = i3k_db_factionBusiness_task[data.id]

	vars.taskName:setText(i3k_get_string(17111)..cfg.name)
	local is_ok = self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, data.value)

	if is_ok then
		vars.taskDesc:setText(i3k_get_string(17112))
		vars.effect1:show()
	else
		vars.taskDesc:setText(self:getCommonTaskDesc(cfg, data.value, data.state, is_ok))
	end
	vars.task_btn:onClick(self, self.doFCBSTask, {type = TASK_CATEGORY_FCBS, cfg = cfg})
	vars.task_btn:setTag(TASK_CATEGORY_FCBS)

	return _layer
end

function wnd_battleTask:doFCBSTask(sender, args)
	local data = g_i3k_game_context:getFactionBusinessTask()
	local cfg = args.cfg
	if self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, data.value) then
		g_i3k_logic:OpenFCBSTaskUI()
	else
		if cfg.type == g_TASK_USE_ITEM then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17126))
		else
			self:gotoTaskPosition(args)
		end
	end
end

function wnd_battleTask:updateFCBSTask(isok)
	local layer = self._scrollItems[TASK_CATEGORY_FCBS]
	if layer and isok ~= nil then
		local data = g_i3k_game_context:getFactionBusinessTask()
		local cfg = i3k_db_factionBusiness_task[data.id]
		if isok then
	  		layer.vars.taskDesc:setText(i3k_get_string(17112))
	  		layer.vars.effect1:show()
	  	else
	  		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, data.value, 1, isok))
		end
	else
		self:removeTaskItem(TASK_CATEGORY_FCBS)
	end
end

-------------------------------------------神兵
function wnd_battleTask:createWeaponTaskItem(loop, id, value1, value2, dayLoopCount)
	if dayLoopCount and dayLoopCount < i3k_db_common.weapontask.Ctasktimes then
		local cfg = g_i3k_db.i3k_db_get_weapon_task_cfg(id,loop)
		local _layer
		local name = i3k_get_string(34)
		name = string.format("%s%s",name, cfg.name)
		if cfg.type2 == 0  then
			local mini_cfg = {id = cfg.id, type = cfg.type1, arg1 = cfg.arg11, arg2 = cfg.arg12, arg3 = cfg.arg13, arg4 = cfg.arg14, arg5 = cfg.arg15, arg6 = cfg.arg16}
			local t = {type = TASK_CATEGORY_WEAPON, id = id, loop = loop, cfg = mini_cfg}
			_layer = self:updateWeaponType(value1,t, name)
		elseif taskType1 == 0 then
		else
		end
		return _layer
	end
end

function wnd_battleTask:updateWeaponType(value,t, name)
	local _layer = require(LAYER_RWLBT)()
	local task_btn = _layer.vars.task_btn
	local taskName = _layer.vars.taskName
	local taskDesc = _layer.vars.taskDesc
	local time_label = _layer.vars.time_label
	local effect1 = _layer.vars.effect1
	local cfg = t.cfg
	effect1:hide()
	time_label:hide()
	local is_ok = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
	local desc = g_i3k_db.i3k_db_get_task_desc(cfg.type, cfg.arg1, cfg.arg2, value,is_ok)

	taskName:setText(name)
	taskDesc:setText(desc)
	task_btn:onClick(self,self.doWeaponTask,t)
	if is_ok then
		effect1:show()
	end
	task_btn:setTag(TASK_CATEGORY_WEAPON)
	return _layer
end

function wnd_battleTask:doWeaponTask(sender, args)
	l_ScrollPercent = self.task_scroll:getListPercent()
	--self._SelectedBtn = args.type
	local cfg = args.cfg
	local value,_ = g_i3k_game_context:getWeaponTaskArgsCountAndArgs()
	local is_ok = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
	if is_ok then
		g_i3k_logic:OpenTaskUI(args.id,args.type)

	else
		local func = function()
			self:gotoTaskPosition(args)
		end
		if g_i3k_game_context:isCanQuickFinishTask(g_QUICK_FINISH_TASK_TYPE_SHENBING, cfg.id) then
			g_i3k_ui_mgr:OpenUI(eUIID_QuickWeaponTaskConfirm)
			g_i3k_ui_mgr:RefreshUI(eUIID_QuickWeaponTaskConfirm, cfg.id, func)
		else
			func()
		end
	end
end

function wnd_battleTask:updateWeaponTask(loop, id, value1, value2, dayLoopCount, args)
	local cfg = g_i3k_db.i3k_db_get_weapon_task_cfg(id,loop)
	local layer = self._scrollItems[TASK_CATEGORY_WEAPON]
	if args and layer then
		local desc = g_i3k_db.i3k_db_get_task_desc(cfg.type1, cfg.arg11, cfg.arg12, value1, args.isOk1)
		if args.type2 == 0 then
			layer.vars.taskDesc:setText(desc)
			if not args.isOk1 then
			else
				if loop == 0 and id == 1 then
					--self.task_scroll:jumpToChildWithIndex(3)
					g_i3k_logic:OpenTaskUI(id,TASK_CATEGORY_WEAPON)
				end
				layer.vars.effect1:show()
			end
		else
		end
	else
		local index = self:removeTaskItem(TASK_CATEGORY_WEAPON)
		local mainTaskItem = self:createWeaponTaskItem(loop, id, value1, value2, dayLoopCount)
		self:updateItemPos(TASK_CATEGORY_WEAPON,mainTaskItem)
	end
end

------------------------------------帮派
function wnd_battleTask:onFinishFactionTask(sender, args)
	local roleID = g_i3k_game_context:getFactionTaskRoleId()
	local my_id = g_i3k_game_context:GetRoleId()
	local d = g_i3k_game_context:getFactionCurrentTask()
	local cfg = args.cfg
	local isfinish = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, d.value)

	if my_id == roleID then
		if isfinish then
			return g_i3k_logic:OpenFactionTaskUI()
		end
	else
		if not self._countdown[TASK_CATEGORY_SECT] or isfinish then
			return g_i3k_logic:OpenFactionShareTaskUI()
		end
	end
	self:gotoTaskPosition(args)
end

function wnd_battleTask:createFactionTaskItem(sid, id, value,roleId,receiveTime,my_id)
	if not sid then
		return
	end
	local max_time = i3k_db_common.faction.share_task_time
	local serverTime = math.modf(i3k_game_get_time())
	local _layer
	if my_id ~= roleId then
		_layer = require(LAYER_RWLBT2)()
	else
		_layer = require(LAYER_RWLBT)()
	end
	local task_btn = _layer.vars.task_btn
	local taskName = _layer.vars.taskName
	local taskDesc = _layer.vars.taskDesc
	local time_label = _layer.vars.taskDesc2

	local effect1 = _layer.vars.effect1
	if effect1 then
		effect1:hide()
	end
	local cfg = g_i3k_db.i3k_db_get_faction_task_cfg(id)
	local is_ok = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2,value)

	taskName:setText(string.format("%s%s",i3k_get_string(36),cfg.name))
	taskDesc:setText(self:getCommonTaskDesc(cfg, value, 1, is_ok))
	task_btn:onClick(self,self.onFinishFactionTask, {type = TASK_CATEGORY_SECT, id = id, cfg = cfg})
	task_btn:setTag(TASK_CATEGORY_SECT)
	if is_ok and effect1 then
		effect1:show()
	end

	local have_time = nil
	if my_id ~= roleId then
		have_time = max_time - (serverTime - receiveTime)
	else
		time_label = _layer.vars.time_label
		time_label:hide()
	end

	return _layer, have_time
end

function wnd_battleTask:updateFactionTask(sid, id, value,roleId,receiveTime,my_id, isok)-- 在协议中调用，刷新任务
	local layer = self._scrollItems[TASK_CATEGORY_SECT]
	if isok ~= nil and layer then
		local cfg = g_i3k_db.i3k_db_get_faction_task_cfg(id)
		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, value, 1, isok))

		if isok then
			if layer.vars.effect1 then
				layer.vars.effect1:show()
			end
		end
	else
		self:removeFactionTaskItem(TASK_CATEGORY_SECT)
		local mainTaskItem, time = self:createFactionTaskItem(sid, id, value,roleId,receiveTime,my_id)
		self:updateItemPos(TASK_CATEGORY_SECT, mainTaskItem, time)
	end
end

function wnd_battleTask:removeFactionTaskItem()
	local index = self:removeTaskItem(TASK_CATEGORY_SECT)
	self:updateMainItemPos(index)
end

function wnd_battleTask:stopFactionTaskTimer()
	self._countdown[TASK_CATEGORY_SECT] = nil
	self:cancelTimer()
end
------------------------------------------------创建帮派运镖

function wnd_battleTask:createFactionEscort()
	local taskId = g_i3k_game_context:GetFactionEscortTaskId()
	local pathId = g_i3k_game_context:GetFactionEscortPathId()
	if not pathId or pathId == 0 then
		return
	end

	local _layer = require(LAYER_RWLBT3)()
	local task_btn = _layer.vars.task_btn
	local taskName = _layer.vars.taskName
	local taskDesc = _layer.vars.taskDesc
	--local time_label = _layer.vars.time_label
	--time_label:hide()

	--local effect1 = _layer.vars.effect1
	--effect1:hide()
	local end_npcid = i3k_db_escort_path[pathId].end_npc
	local main_mapID = g_i3k_db.i3k_db_get_npc_map_by_npc_point(end_npcid)

	local npcName = i3k_db_npc[g_i3k_db.i3k_db_get_npc_id_by_npc_point(end_npcid)].remarkName
	local mapName = i3k_db_dungeon_base[main_mapID].desc
	taskName:setText(i3k_get_string(532))
	taskDesc:setText(i3k_get_string(533,mapName,npcName))

	task_btn:onClick(self,self.onEscortPos)
	task_btn:setTag(TASK_CATEGORY_ESCORT)
	return _layer
end

function wnd_battleTask:onEscortPos(sender)
	local id = g_i3k_game_context:GetFactionEscortPathId()
	if id ~= 0 then
		local end_npcid = i3k_db_escort_path[id].end_npc
		local main_point = g_i3k_db.i3k_db_get_npc_postion_by_npc_point(end_npcid)
		local main_mapID = g_i3k_db.i3k_db_get_npc_map_by_npc_point(end_npcid)
		local hero = i3k_game_get_player_hero()
		local NPCID = i3k_db_npc_area[end_npcid].NPCID
		main_point = g_i3k_game_context:getNPCRandomPos(NPCID)
		local carSpeed = g_i3k_game_context:GetCurCarSpeed()
		g_i3k_game_context:SetTmpCarState(true)
		g_i3k_game_context:SeachPathWithMap(main_mapID,main_point,TASK_CATEGORY_ESCORT, nil, nil, carSpeed)
	end
end

--更新帮派运镖
function wnd_battleTask:updateFactionEscort()
	self:removeTaskItem(TASK_CATEGORY_ESCORT)
	local mainTaskItem = self:createFactionEscort()
	self:updateItemPos(TASK_CATEGORY_ESCORT,mainTaskItem)
end

function wnd_battleTask:RemoveFactionEscortTaskItem()
	local index = self:removeTaskItem(TASK_CATEGORY_ESCORT)
	self:updateMainItemPos(index)
end

------------------------------ 秘境任务
function wnd_battleTask:createSecretareaTaskItem()--任务id
	--self:onUpdatebuttonState(id,value)
	local secretareaId,finishValue,reward = g_i3k_game_context:getSecretareaTaskId()--在协议里设置
	if not secretareaId or secretareaId <= 0 then
		return
	end
	local id,value = g_i3k_game_context:getSecretareaTaskIdAndVlaue()

	local _layer = require(LAYER_RWLBT)()
	local task_btn = _layer.vars.task_btn
	local taskName = _layer.vars.taskName
	local taskDesc = _layer.vars.taskDesc
	local time_label = _layer.vars.time_label
	local effect1 = _layer.vars.effect1
	effect1:hide()
	time_label:hide()

	local cfg = i3k_db_secretarea_task[id]
	local is_ok = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)

	local desc = g_i3k_db.i3k_db_get_task_desc(cfg.type, cfg.arg1, cfg.arg2, value, is_ok)
	taskName:setText(string.format("%s%s",cfg.prename,cfg.name))
	taskDesc:setText(desc)

	task_btn:onClick(self,self.onFinishSecretareaTask, {type = TASK_CATEGORY_SECRETAREA , cfg = cfg})

	task_btn:setTag(TASK_CATEGORY_SECRETAREA)--设置任务类型
	return _layer
end

----刷新秘境任务
function wnd_battleTask:updateSecretareaTask(id, value, isOk)
	self.isSearchPath = true
	local layer = self._scrollItems[TASK_CATEGORY_SECRETAREA]
	if isOk ~= nil and layer then
		local cfg = i3k_db_secretarea_task[id]
		local desc = g_i3k_db.i3k_db_get_task_desc(cfg.type, cfg.arg1, cfg.arg2, value, isOk)
		layer.vars.taskDesc:setText(desc)
	else
		local index = self:removeTaskItem(TASK_CATEGORY_SECRETAREA)
		local secretareaTaskItem = self:createSecretareaTaskItem(id, value)
		self:updateItemPos(TASK_CATEGORY_SECRETAREA,secretareaTaskItem)
	end
end

function wnd_battleTask:onFinishSecretareaTask(sender,args)
	l_ScrollPercent = self.task_scroll:getListPercent()
	local cfg = args.cfg
	--判断是否处于秘境地图 mapId
	local id,value = g_i3k_game_context:getSecretareaTaskIdAndVlaue()
	local now_mapId = g_i3k_game_context:GetWorldMapID()
	local point = g_i3k_db.i3k_db_get_monster_pos(cfg.arg1)
	local isFinish = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
	local function func()
	if now_mapId == cfg.mapId then--处于秘境地图(不能领奖，可以寻路)
			if isFinish then --完成
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(538))
		else
			---寻路
			g_i3k_game_context:SeachPathWithMap(now_mapId, point,TASK_CATEGORY_SECRETAREA)

		end
	else--(领奖，弹窗)
		local infoTb = g_i3k_game_context:getSecretareaTaskInfo()
		g_i3k_ui_mgr:OpenUI(eUIID_Secretarea)
		g_i3k_ui_mgr:RefreshUI(eUIID_Secretarea,infoTb)
		end
	end
	if g_i3k_game_context:isCanQuickFinishTask(g_QUICK_FINISH_FIVE_UNIQUE, cfg.type) and not isFinish then
		g_i3k_ui_mgr:OpenUI(eUIID_QuickWeaponTaskConfirm)
		g_i3k_ui_mgr:RefreshUI(eUIID_QuickWeaponTaskConfirm, id, func, g_QUICK_FINISH_FIVE_UNIQUE)
	else
		func()
	end
end

function wnd_battleTask:removeSecreTaskItem()
	local index = self:removeTaskItem(TASK_CATEGORY_SECRETAREA)
	self:updateMainItemPos(index)
end


-------------------------------------------龙穴任务
function wnd_battleTask:initDragonTask()
	self:removeTaskItem(TASK_CATEGORY_DRAGON_HOLE)
	for k, v in ipairs(g_i3k_game_context:GetAcceptDragonHoleTask()) do
		local taskItem, time = self:createDragonTaskItem(v.id, v.value, v.receiveTime)
		self:updateItemPos(v.id + 100, taskItem, time)
	end
end

function wnd_battleTask:createDragonTaskItem(id, value, time)
	local node = require(LAYER_RWLBT2)()
	local max_time = i3k_db_dragon_hole_cfg.lastTime
	local serverTime = i3k_game_get_time()
	local cfg = g_i3k_db.i3k_db_get_dragon_task_cfg(id)
	local is_ok = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
	node.vars.taskName:setText(string.format("%s%s", i3k_get_string(16979), cfg.name))
	node.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, value, 1, is_ok))
	node.vars.task_btn:onClick(self, self.onFinishDragonTask, {type = TASK_CATEGORY_DRAGON_HOLE, cfg = cfg, otherId = id})
	return node, time + max_time - serverTime
end

function wnd_battleTask:onFinishDragonTask(sender, data)
	l_ScrollPercent = self.task_scroll:getListPercent()
	local taskCfg = g_i3k_game_context:isAcceptDragonHoleTask(data.otherId)
	if not g_i3k_db.i3k_db_is_valid_dragon_task(taskCfg.receiveTime) then
		g_i3k_logic:OpenDragonTaskUI()
		return
	end
	local isFinished = g_i3k_game_context:IsTaskFinished(data.cfg.type, data.cfg.arg1, data.cfg.arg2, taskCfg.value)
	if isFinished then
		g_i3k_logic:OpenDragonTaskUI()
		return
	else
		self:gotoTaskPosition(data)
	end
end

function wnd_battleTask:removeDragonHoleTask(taskId)
	local index = self:removeTaskItem(taskId + 100)
	self:updateMainItemPos(index)
end

function wnd_battleTask:updateDragonHoleTask(isFinished, taskId)
	local curDragonTask = g_i3k_game_context:isAcceptDragonHoleTask(taskId)
	local layer = self._scrollItems[taskId + 100]
	if isFinished ~= nil and layer then
		local cfg = g_i3k_db.i3k_db_get_dragon_task_cfg(taskId)
		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, curDragonTask.value, 1, isFinished))
		if isFinished then
			if layer.vars.effect1 then
				layer.vars.effect1:show()
			end
		end
	else
		self:removeDragonHoleTask(taskId)
		local taskItem, time = self:createDragonTaskItem(taskId, curDragonTask.value, curDragonTask.receiveTime)
		self:updateItemPos(taskId + 100, taskItem, time)
	end
end
-------------------------限时任务
function wnd_battleTask:initLimitTask()
	if self._scrollItems[TASK_CATEGORY_LIMIT] then
		self:removeTaskItem(TASK_CATEGORY_LIMIT)
	end
	local data = g_i3k_game_context:getLimitTimeTask()
	if data.taskID == 0 then
		return
	end
	local cfg = i3k_db_limitTask[data.taskID]
	local time = data.receiveTime + cfg.limitTime - i3k_game_get_time()
	local node = require(LAYER_LIMIT)()
	local widgets = node.vars
	widgets.taskName:setText(i3k_get_string(17011).. cfg.name)
	widgets.des2:setText(cfg.desc)

	local itemId = cfg.awardIds[g_i3k_game_context:GetRoleType()]
	widgets.itembg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
	widgets.itembg:onClick(self, self.onItemTips, itemId)
	widgets.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
	self:setUpIsShow(itemId,widgets.overIcon)
	widgets.task_btn:onClick(self, self.onLimitTask)
	widgets.task_btn:setTag(TASK_CATEGORY_LIMIT)
	if time > 0 then
		self:updateItemPos(TASK_CATEGORY_LIMIT, node, time)
	elseif cfg.resetTask then
		self:updateItemPos(TASK_CATEGORY_LIMIT, node)
		widgets.time_label:setText(i3k_get_string(17013))
		widgets.time_label:setTextColor(g_i3k_get_cond_hl_color(false))
	end
end

function wnd_battleTask:setUpIsShow(id, upImg)
	if g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP then
		local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
		local bwType = g_i3k_game_context:GetTransformBWtype()
		local isSameBwType = equip_cfg.M_require == 0 or equip_cfg.M_require == bwType

		if (g_i3k_game_context:GetRoleType() == equip_cfg.roleType or equip_cfg.roleType == 0) and isSameBwType then
			local wearEquips = g_i3k_game_context:GetWearEquips()
			local _data = wearEquips[equip_cfg.partID].equip
			if _data then
				local wAttribute = _data.attribute
				local wNaijiu = _data.naijiu
				local wEquip_id = _data.equip_id
				local wPower = g_i3k_game_context:GetBagEquipPower(wEquip_id,wAttribute,wNaijiu, _data.refine, _data.legends, _data.smeltingProps)
				local total_power = g_i3k_game_context:GetBagEquipPower(id,self:getEquipExtMinProperties(id),-1,{},{})
				upImg:show()
				if wPower > total_power then
					upImg:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				elseif wPower < total_power then
					upImg:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				else
					upImg:hide()
				end
			else
				upImg:show():setImage(g_i3k_db.i3k_db_get_icon_path(174))
			end
		else
			upImg:hide()
		end
	else
		upImg:hide()
	end
end

function wnd_battleTask:stopLimitTaskTimer()
	self._countdown[TASK_CATEGORY_LIMIT] = nil
	self:cancelTimer()
end

function wnd_battleTask:resetLimitTaskTimer( )
	local data = g_i3k_game_context:getLimitTimeTask()
	local cfg = i3k_db_limitTask[data.taskID]
	local time = data.receiveTime + cfg.limitTime - i3k_game_get_time()
	local item = self._scrollItems[TASK_CATEGORY_LIMIT]
	if item then
		self:addTaskTimeDown(TASK_CATEGORY_LIMIT, time, item.vars.time_label)
	else
		self:initLimitTask()
	end
end

function wnd_battleTask:onLimitTask(sender)
	local data = g_i3k_game_context:getLimitTimeTask()
	local cfg = i3k_db_limitTask[data.taskID]
	local time = data.receiveTime + cfg.limitTime - i3k_game_get_time()
	if time > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17014))
	else
		g_i3k_ui_mgr:ShowCustomMessageBox1("确定",i3k_get_string(17015),function( )
			i3k_sbean.tmtask_reactiveReq()
		end)
	end
end

----------------------------------------珍珑棋局任务
function wnd_battleTask:createChessTaskItem()
	local time = g_i3k_db.i3k_db_get_chess_task_left_time()
	local chessTask = g_i3k_game_context:getChessTask()
	if chessTask then
		local _layer = require(LAYER_RWLBTZLQJ)()
		_layer.vars.task_btn:setTag(TASK_CATEGORY_CHESS)
		_layer.vars.chessValue:setText(string.format("棋力值：%s", chessTask.chessValue))
		if chessTask.curTaskID > 0 then
			local cfg = i3k_db_chess_task[chessTask.curTaskID]
			local isok = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, chessTask.curValue)
			_layer.vars.taskName:setText(string.format("%s%s", string.format(cfg.prename, loopDesc[chessTask.loopLvl]), cfg.name))
			_layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, chessTask.curValue, 1, isok))
		elseif chessTask.needUpLoopLvl == 1 then
			_layer.vars.taskName:setText(string.format("<c=FFFF00FF>[棋局·%s]</c>举棋不定", loopDesc[chessTask.loopLvl]))
			_layer.vars.taskDesc:setText(i3k_get_string(17274))
		else
			_layer.vars.taskName:setText(i3k_get_string(17324))
			_layer.vars.taskDesc:setText(i3k_get_string(17323))
		end
		_layer.vars.task_btn:onClick(self, self.doChessTask)
		return _layer, time
	end
end

function wnd_battleTask:updateChessTaskTag(isAuto)
	local _layer = self._scrollItems[TASK_CATEGORY_CHESS].vars
	local chessTask = g_i3k_game_context:getChessTask()
	if chessTask.curTaskID > 0 then
		local cfg = i3k_db_chess_task[chessTask.curTaskID]
		local isok = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, chessTask.curValue)
		_layer.taskDesc:setText(self:getCommonTaskDesc(cfg, chessTask.curValue, 1, isok))
		if chessTask.state >= 1 and is_ok then
			self.isSearchPath = isAuto
			self:onFinishChessTask(cfg)
			return
		end
		if isAuto then
			g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_CHESS, cfg)
		end
	end
end

function wnd_battleTask:updateChessTask(isok)
	local layer = self._scrollItems[TASK_CATEGORY_CHESS]
	if layer and isok ~= nil then
		local data = g_i3k_game_context:getChessTask()
		local cfg = i3k_db_chess_task[data.curTaskID]
	  	layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, data.curValue, 1, isok))
		layer.vars.chessValue:setText(string.format("棋力值：%s", data.chessValue))
		if isok and cfg.type == g_TASK_NEW_NPC_DIALOGUE then
			self:finishTask(cfg, TASK_CATEGORY_CHESS)
		end
	else
		self:removeTaskItem(TASK_CATEGORY_CHESS)
		local taskItem, time = self:createChessTaskItem()
		self:updateItemPos(TASK_CATEGORY_CHESS, taskItem, time)
	end
end

function wnd_battleTask:doChessTask(sender)
	local data = g_i3k_game_context:getChessTask()
	if data.curTaskID > 0 then
		local cfg = i3k_db_chess_task[data.curTaskID]
		if self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, data.curValue) then
			self:onFinishChessTask(cfg)
		else
			local args = {type = TASK_CATEGORY_CHESS, cfg = cfg}
			self:doTask(args, 1, data.curValue)
		end
	elseif data.needUpLoopLvl == 1 then
		g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskThink)
		g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskThink)
	else
		i3k_sbean.chess_game_receive()
	end
end

function wnd_battleTask:onFinishChessTask(cfg)
	self:finishTask(cfg, TASK_CATEGORY_CHESS)
	--[[if i3k_db_chess_task[chessTask.curTaskID].finishTaskNpcID == 0 then
		g_i3k_game_context:finishChessTaskDialogue()
	else
		if i3k_db_chess_task[chessTask.curTaskID].type ~= g_TASK_REACH_LEVEL then
			self:transportToNpc(i3k_db_chess_task[chessTask.curTaskID].finishTaskNpcID, TASK_CATEGORY_CHESS)
		end
	end--]]
end

function wnd_battleTask:stopChessTaskTimer()
	self._countdown[TASK_CATEGORY_CHESS] = nil
	self:cancelTimer()
end

----------------------------------------------------------------------



function wnd_battleTask:getEquipExtMinProperties(id)
	local cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
	local ext_properties = { }
	for _,e in ipairs(cfg.ext_properties) do
		if e.args ~= 0 then
			table.insert(ext_properties, e.minVal)
		end
	end
	return ext_properties
end

function wnd_battleTask:onItemTips(sender, id)
	if g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP then
		local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
		if g_i3k_game_context:isFlyEquip(equipCfg.partID) then
			g_i3k_ui_mgr:OpenUI(eUIID_FlyingEquipInfo)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipInfo, "updateBagEquipInfo", {equip_id = id, equip_guid = 0, naijiu = -1, attribute = self:getEquipExtMinProperties(id), refine = {}, legends = {}}, false, true)
		else
		g_i3k_ui_mgr:OpenUI(eUIID_EquipTips)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTips, "updateBagEquipInfo",{equip_id = id, equip_guid = 0, naijiu = -1, attribute = self:getEquipExtMinProperties(id), refine = {}, legends = {}}, false, true)
		end
	else
		g_i3k_ui_mgr:ShowCommonItemInfo(id)
	end
end

-------------------------------------------
function wnd_battleTask:addTaskTimeDown(taskCategory, have_time, node)
	self._countdown[taskCategory] = {time = have_time, node = node, color = nil}
	self:setFactionTaskTime()
	if not self._faction_task_timer then
		self._faction_task_timer = i3k_game_timer_battle.new()
		self._faction_task_timer:onTest()
	end
end

function wnd_battleTask:getTimeStr(time)
	local hour =math.modf(time/(60*60))
	local minite = math.modf((time - hour*60*60)/60)
	local sec = math.modf((time - hour*60*60 - minite *60))

	return string.format("%02d:%02d:%02d",hour,minite,sec)
end

function wnd_battleTask:setFactionTaskTime()
	for k,v in pairs(self._countdown) do
		if g_i3k_db.i3k_db_check_festival_task_by_hash_id(k) then
			local groupId, taskId = g_i3k_db.i3k_db_get_festival_task_real_id(k)
			local activityId = i3k_db_festival_task[groupId][taskId].activityId
			local time, isOpen = g_i3k_db.i3k_db_get_festival_end_time(activityId)
			if isOpen then
				v.node:setText(time)
				v.node:setTextColor(g_i3k_get_cond_hl_color(false))
			else
				self:removeTaskItem(k)
				g_i3k_game_context:addFestivalLimitTask(activityId)
			end
		else
			v.time = v.time - 1
			if k == TASK_CATEGORY_DETECTIVE then
				if v.time < 0 then
					self:removeDetectiveTask()
				end
			else
			local str = nil
			local color = true
			if v.time < 0 then
				if k == TASK_CATEGORY_SECT then
					str = "任务失败"
					self:stopFactionTaskTimer()
				elseif k == TASK_CATEGORY_STELA then
					self:removeStelaTaskItem()
					return
				elseif k == TASK_CATEGORY_LIMIT then
					str = i3k_get_string(17013)
					self:stopLimitTaskTimer()
				elseif k == TASK_CATEGORY_ADVENTURE then
					self:removeTaskItem(TASK_CATEGORY_ADVENTURE)
					self:stopLimitTaskTimer()
					return
				elseif k == TASK_CATEGORY_CHESS then
					self:removeTaskItem(TASK_CATEGORY_CHESS)
					self:stopChessTaskTimer()
				elseif k > 100 then
					str = "任务失败"
					self:removeDragonHoleTask(k - 100)
				end
				color = false
			else
				str = self:getTimeStr(v.time)
				color = true
				if v.time < 60 then
					color = false
				end
			end
			if v.color ~= color then
				v.node:setTextColor(g_i3k_get_cond_hl_color(color))
				v.color = color
			end
			if k == TASK_CATEGORY_CHESS and v.time < 0 then
			else
				v.node:setText(str)
				end
			end
		end
	end
end

----------------
local TIMER = require("i3k_timer");
i3k_game_timer_battle = i3k_class("i3k_game_timer_battle", TIMER.i3k_timer);

function i3k_game_timer_battle:Do(args)
	--i3k_log("i3k_game_timer_battle");
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"setFactionTaskTime")
end

function i3k_game_timer_battle:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._Timer_a = logic:RegisterTimer(i3k_game_timer_battle.new(1000));
	end
end

function i3k_game_timer_battle:CancelTimer()
	local logic = i3k_game_get_logic();
	if logic and self._Timer_a then
		logic:UnregisterTimer(self._Timer_a);
	end
end
-----------

function wnd_battleTask:removeTaskItem(taskType)
	local items = self.task_scroll:getAllChildren()
	for k, v in ipairs(items) do
		local a = v.vars.task_btn:getTag()
		if a == taskType then
			self.task_scroll:removeChildAtIndex(k)
			self._scrollItems[taskType] = nil
			self._countdown[taskType] = nil
			self:cancelTimer()
			return k;
		end
	end
	return #items +1
end

function wnd_battleTask:gotoTaskPosition(args)
	if args.type == i3k_get_MrgTaskCategory() then
		g_i3k_game_context:CoupleDoTask(true, true)
	end
	g_i3k_game_context:GoingToDoTask(args.type , args.cfg, args.otherId)
end

---------------------------------------------------------
function wnd_battleTask:onTaskBtn(sender,args)
	l_ScrollPercent = self.task_scroll:getListPercent()
	self._SelectedBtn = args.type
	g_i3k_logic:OpenTaskUI(args.id,args.type)
end

function wnd_battleTask:updateItemPos(taskType,item, time)
	if item then
		if taskType == TASK_CATEGORY_MAIN then
			local id,value = g_i3k_game_context:getMainTaskIdAndVlaue()
			local main_cfg = g_i3k_db.i3k_db_get_main_task_cfg(id)
			local tm_task_type = main_cfg.type
			local index = 1
			if tm_task_type == g_TASK_REACH_LEVEL then
				local is_ok = g_i3k_game_context:IsTaskFinished(tm_task_type, main_cfg.arg1, main_cfg.arg2, value)
				index = is_ok and 1 or 2
			end
			self.task_scroll:insertChildToIndex(item, index)
		else
			local mIndex = g_i3k_game_context:GetMainTaskIndex()

			if mIndex == 2 then
				self:removeTaskItem(TASK_CATEGORY_MAIN)
				self.task_scroll:insertChildToIndex(item, 1)
				self:InsertMainTaskToSecondPos()
			else
				self.task_scroll:insertChildToIndex(item, 2)
			end
		end
		self:updateTaskLayer(taskType, item, time)
		l_ScrollPercent = 0
		if TASK_CATEGORY_LIMIT ~= taskType then
			self:initLimitTask()
		end
		self.task_scroll:jumpToListPercent(0)
	end
end

function wnd_battleTask:InsertMainTaskToSecondPos()
	local newItem = self:createMainTaskItem()
	self.task_scroll:insertChildToIndex(newItem, 2)
	self:updateTaskLayer(TASK_CATEGORY_MAIN, newItem)
end

function wnd_battleTask:updateMainItemPos(index)
	if index == 1 and g_i3k_game_context:GetMainTaskIndex() == 2 then
		self:removeTaskItem(1)
		self:InsertMainTaskToSecondPos()
	end
end

function wnd_battleTask:transportToNpc(npcID,taskType,arg)
	local point1 = g_i3k_db.i3k_db_get_npc_pos(npcID);
	local mapID = g_i3k_db.i3k_db_get_npc_map_id(npcID);
	local point = g_i3k_game_context:getNPCRandomPos(npcID)
	local needValue = {flage = 1, mapId = mapID, areaId = npcID, pos = point, npcPos = point1}

	local isCan = g_i3k_game_context:doTransport(needValue)
	if not isCan then
		g_i3k_game_context:SeachPathWithMap(mapID,point,taskType,arg,needValue)
	end
end

---------------------------------------
-- 势力声望任务
function wnd_battleTask:createPowerRepTaskItem(taskCat)
	-- 在做完任务的时候，g_i3k_game_context中的self._TaskListOrder字段并不会删掉，而要做处理，如果创建出来的是空，那么就返回个nil
	local cfg = g_i3k_game_context:getPowerRepTask(taskCat) -- 可能会崩溃
	if cfg and cfg.state == 3 then -- 接取1， 0未接取，2完成，3领过奖了
		-- g_i3k_ui_mgr:PopupTipMessage(cfg.state)
		return
	end

	local taskCfg = g_i3k_db.i3k_db_power_rep_get_taskCfg_by_hash(taskCat)
	if not taskCfg then
		error("taskCfg is a nil value, groupID:"..groupID.." id:"..id)
		return
	end
	local _layer = require(LAYER_RWLBT)()
	local task_btn = _layer.vars.task_btn
	local taskName = _layer.vars.taskName
	local time_label = _layer.vars.time_label
	local taskDesc = _layer.vars.taskDesc
	local effect1 = _layer.vars.effect1

	effect1:hide()
	time_label:hide()
	local curValue = 20
	local desc = g_i3k_db.i3k_db_get_task_desc(taskCfg.taskConditionType, taskCfg.args[1], taskCfg.args[2], curValue, false)
	local name = string.format("%s%s", i3k_get_string(17265), taskCfg.taskName)
	taskName:setText(name)
	taskDesc:setText(desc)
	task_btn:setTag(taskCat)
	task_btn:onClick(self, self.doPowerRepTask, {type = TASK_CATEGORY_POWER_REP, otherId = taskCat})
	return _layer
end

function wnd_battleTask:doPowerRepTask(sender, info)
	local hash = info.otherId
	local curTaskState = g_i3k_game_context:getPowerRepTask(hash)
	local taskCfg = g_i3k_db.i3k_db_power_rep_get_taskCfg_by_hash(hash)
	local cfg = g_i3k_db.i3k_db_power_rep_convert_db(taskCfg) -- 两种db的格式转换一下
	local args = {type = info.type, cfg = cfg, otherId = hash}
	local hashCfg = g_i3k_game_context:getPowerRepTask(hash)
	local is_ok = self:getTaskIsfinish(taskCfg.taskConditionType, taskCfg.args[1], taskCfg.args[2], hashCfg.value)
	if is_ok then
		local groupID, id = g_i3k_db.i3k_db_get_power_rep_task_real_id(hash)
		i3k_sbean.finishPowerReqTask(groupID, id)
		return
	end
	self:doTask(args, curTaskState.state, curTaskState.value)
end

function wnd_battleTask:updatePowerRepTask(hash, value, isok)
	local layer = self._scrollItems[hash]
	if layer and isok ~= nil then
		local curTask = g_i3k_game_context:getPowerRepTask(hash)
		local taskCfg = g_i3k_db.i3k_db_power_rep_get_taskCfg_by_hash(hash)
		local cfg = g_i3k_db.i3k_db_power_rep_convert_db(taskCfg)
	  	layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, curTask.value, 1, isok))
	else
		self:removeTaskItem(hash)
		local taskItem = self:createPowerRepTaskItem()
		self:updateItemPos(hash, taskItem)
	end
end

function wnd_battleTask:updatePowerRepTaskTag(hash, isAuto)
	local taskCfg = g_i3k_db.i3k_db_power_rep_get_taskCfg_by_hash(hash)
	local _layer = self._scrollItems[hash].vars
	local cfg = g_i3k_game_context:getPowerRepTask(hash)
	local is_ok = self:getTaskIsfinish(taskCfg.taskConditionType, taskCfg.args[1], taskCfg.args[2], cfg.value)
	local desc = g_i3k_db.i3k_db_get_task_desc(taskCfg.taskConditionType, taskCfg.args[1], taskCfg.args[2], cfg.value, is_ok)
	_layer.taskDesc:setText(desc)
	if isAuto then
	end
end

--节日限时任务
function wnd_battleTask:createFestivalTaskItem(taskCat)
	local groupId, taskId = g_i3k_db.i3k_db_get_festival_task_real_id(taskCat)
	local taskInfo = i3k_db_festival_task[groupId][taskId]
	local endTime, isInData = g_i3k_db.i3k_db_get_festival_end_time(taskInfo.activityId)
	if isInData then
		local _layer = require(LAYER_RWLBT2)()
		_layer.vars.task_btn:setTag(TASK_CATEGORY_FESTIVAL)
		_layer.vars.taskName:setText(i3k_get_string(taskInfo.taskPrefix)..taskInfo.name)
		_layer.vars.task_btn:onClick(self, self.doFestivalTask, {type = TASK_CATEGORY_FESTIVAL, id = taskId, otherId = taskCat, cfg = taskInfo})
		return _layer, endTime
		--return _layer
	end
end

function wnd_battleTask:doFestivalTask(sender, args)
	l_ScrollPercent = self.task_scroll:getListPercent()
	self._SelectedBtn = args.otherId
	local groupId, taskId = g_i3k_db.i3k_db_get_festival_task_real_id(args.otherId)
	local task = g_i3k_game_context:getFestivalTaskValue(groupId, args.id)
	local cfg = args.cfg
	if task.state == 0 then
		return self:doGetFestivalTask(args)
	end
	if task.state >= 1 and self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, task.value) then
		self.isSearchPath = true
		return self:finishFestivalTask(groupId, args.id, args.cfg)
	end
	self:gotoTaskPosition(args)
end

function wnd_battleTask:doGetFestivalTask(args)
	local cfg = args.cfg
	if g_i3k_game_context:CheckTransformationTaskState(cfg.effectIdList) and not g_i3k_game_context:IsInMetamorphosisMode() then
		g_i3k_ui_mgr:PopupTipMessage("请先完成当前变身任务")
		return
	end
	local groupId, taskId = g_i3k_db.i3k_db_get_festival_task_real_id(args.otherId)
	if cfg.getTaskNpcID == 0 then
		g_i3k_game_context:GetFestivalTaskDialogue(groupId, args.id)
	else
		self:transportToNpc(cfg.getTaskNpcID, TASK_CATEGORY_FESTIVAL, args.otherId)
	end
end

function wnd_battleTask:updateFestivalTaskTag(btnIndex, isAuto)
	local data = g_i3k_game_context:getFestivalLimitTask()
	local groupId, taskId = g_i3k_db.i3k_db_get_festival_task_real_id(btnIndex)
	for k, v in pairs(data) do
		if v.curTask and v.curTask.groupId == groupId then
			local cfg = i3k_db_festival_task[groupId][taskId]
			local _layer = self._scrollItems[btnIndex].vars
			local is_ok = self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, v.curTask.value)
			_layer.taskDesc:setText(self:getCommonTaskDesc(cfg, v.curTask.value, v.curTask.state, is_ok))
			if v.curTask.state >= 1 and is_ok then
				self.isSearchPath = isAuto
				self:finishFestivalTask(groupId, taskId, cfg)
				return
			end
			if isAuto then
				g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_FESTIVAL, cfg, btnIndex)
			end
			return
		end
	end
end

function wnd_battleTask:updateFestivalTask(groupId, taskId, isOk)
	self.isSearchPath = true
	local tag = g_i3k_db.i3k_db_get_festival_task_hash_id(groupId, taskId)
	local layer = self._scrollItems[tag]
	if layer and isOk ~= nil then
		local cfg = i3k_db_festival_task[groupId][taskId]
		local data = g_i3k_game_context:getFestivalTaskValue(groupId, taskId)
		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, data.value, 1, isOk))
		if isOk then
			if cfg.type == g_TASK_USE_ITEM and cfg.arg4 == 0 and data.value == 0 then
				self.isSearchPath = false
			end
			self:finishFestivalTask(groupId, taskId, cfg)
		end
	else
		local index = self:removeTaskItem(tag)
		local taskItem = self:createFestivalTaskItem(tag)
		self:updateItemPos(tag, taskItem)
	end
end

function wnd_battleTask:finishFestivalTask(groupId, taskId, cfg)
	if self._SelectedBtn == g_i3k_db.i3k_db_get_festival_task_hash_id(groupId, taskId) and self.isSearchPath then
		if cfg.finishTaskNpcID == 0 then
			g_i3k_game_context:finishFestivalDialogue(groupId, taskId)
		else
			if taskType ~= g_TASK_REACH_LEVEL then
				self:transportToNpc(cfg.finishTaskNpcID, TASK_CATEGORY_FESTIVAL, g_i3k_db.i3k_db_get_festival_task_hash_id(groupId, taskId))
			end
		end
	end
end

-- 周年庆活动任务 begin
function wnd_battleTask:createJubileeTaskItem(taskType)
	local taskId = g_i3k_game_context:GetJubileeStep2TaskID()
	local taskInfo = g_i3k_db.i3k_db_get_jubilee_task_cfg(taskId)
	local _layer = require(LAYER_RWLBT)()
	_layer.vars.task_btn:setTag(TASK_CATEGORY_JUBILEE)
	_layer.vars.effect1:hide()
	_layer.vars.time_label:hide()
	_layer.vars.taskName:setText(string.format("%s%s", taskInfo.prename, taskInfo.name))
	_layer.vars.task_btn:onClick(self, self.doJubileeTask, {type = TASK_CATEGORY_JUBILEE, id = taskId, otherId = taskType, cfg = taskInfo})
	return _layer
end
function wnd_battleTask:doJubileeTask(sender, args)
	l_ScrollPercent = self.task_scroll:getListPercent()
	self._SelectedBtn = args.otherId
	local task = g_i3k_game_context:GetJubileeStep2Task()
	local cfg = args.cfg
	if task.state == 0 then
		return self:doGetJubileeTask(args)
	end
	if task.state >= 1 and self:getTaskIsfinish(cfg.type, cfg.arg1, cfg.arg2, task.value) then
		self.isSearchPath = true
		return self:finishJubileeTask(cfg)
	end
	self:gotoTaskPosition(args)
end
function wnd_battleTask:doGetJubileeTask(args)
	local cfg = args.cfg
	if g_i3k_game_context:CheckTransformationTaskState(cfg.effectIdList) and not g_i3k_game_context:IsInMetamorphosisMode() then
		g_i3k_ui_mgr:PopupTipMessage("请先完成当前变身任务")
		return
	end
	if cfg.getTaskNpcID == 0 then
		g_i3k_game_context:GetJubileeTaskDialogue()
	else
		self:transportToNpc(cfg.getTaskNpcID, TASK_CATEGORY_JUBILEE)
	end
end
function wnd_battleTask:updateJubileeTaskTag(btnIndex, isAuto)
	local jubileeTask = g_i3k_game_context:GetJubileeStep2Task()
	if jubileeTask.id > 0 then
		local _layer = self._scrollItems[btnIndex].vars
		local cfg = g_i3k_db.i3k_db_get_jubilee_task_cfg(jubileeTask.id)
		local isok = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, jubileeTask.value)
		_layer.taskDesc:setText(self:getCommonTaskDesc(cfg, jubileeTask.value, jubileeTask.state, isok))
		if jubileeTask.state >= 1 and is_ok then
			self.isSearchPath = isAuto
			self:finishTask(cfg, TASK_CATEGORY_JUBILEE)
			return
		end
		if isAuto then
			g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_JUBILEE, cfg)
		end
	end
end
-- InvokeUIFunction
function wnd_battleTask:updateJubileeTask(isOk)
	self.isSearchPath = true
	local layer = self._scrollItems[TASK_CATEGORY_JUBILEE]
	if layer and isOk ~= nil then
		local data = g_i3k_game_context:GetJubileeStep2Task()
		local cfg = g_i3k_db.i3k_db_get_jubilee_task_cfg(data.id)
		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, data.value, 1, isOk))
		if isOk then
			if cfg.type == g_TASK_USE_ITEM and cfg.arg4 == 0 and data.value == 0 then
				self.isSearchPath = false
			end
			self:finishJubileeTask(cfg)
		end
	end
end
function wnd_battleTask:finishJubileeTask(cfg)
	if self._SelectedBtn == TASK_CATEGORY_JUBILEE and self.isSearchPath then
		if cfg.finishTaskNpcID <= 0 then
			g_i3k_game_context:finishJubileeDialogue()
		else
			if taskType ~= g_TASK_REACH_LEVEL then
				self:transportToNpc(cfg.finishTaskNpcID, TASK_CATEGORY_JUBILEE)
			end
		end
	end
end
function wnd_battleTask:removeJubileeTaskItem()
	local index = self:removeTaskItem(TASK_CATEGORY_JUBILEE)
	self:updateMainItemPos(index)
end
-- 周年庆活动任务 end
--江湖侠探任务
function wnd_battleTask:createDetectiveItem()
	local taskId, isMember = g_i3k_game_context:getKnightlyDetectiveTaskId()
	local time = g_i3k_game_context:isKnightlyDetectiveOpen()
	if taskId == -1 then
	else
		local _layer = require(LAYER_RWLBT)()
		_layer.vars.time_label:hide()
		_layer.vars.effect1:hide()
		if taskId == 0 then
			if isMember then
				_layer.vars.taskName:setText(i3k_get_string(18202))
			else
				_layer.vars.taskName:setText(i3k_get_string(18218))
			end
			_layer.vars.task_btn:onClick(self, self.openDetectiveUI)
		else
			local taskCfg = g_i3k_db.i3k_db_get_knightly_detective_task_cfg(taskId)
			local name = string.format("%s%s", taskCfg.prefixName, taskCfg.name)
			_layer.vars.taskName:setText(name)
			_layer.vars.task_btn:onClick(self, self.doDetectiveTask, {type = TASK_CATEGORY_DETECTIVE, id = taskId, cfg = taskCfg})
			_layer.vars.task_btn:setTag(TASK_CATEGORY_DETECTIVE)
		end
		return _layer, time
	end
end
function wnd_battleTask:updateDetectiveTaskTag()
	if self._scrollItems[TASK_CATEGORY_DETECTIVE] then
		local _layer = self._scrollItems[TASK_CATEGORY_DETECTIVE].vars
		local taskId, isMember = g_i3k_game_context:getKnightlyDetectiveTaskId()
		if taskId == 0 then
			if isMember then
				_layer.taskDesc:setText(i3k_get_string(18203))
			else
				local sypData = g_i3k_game_context:getKnightlyDetectiveData()
				if sypData and sypData.bossFond == g_DETECTIVE_NOT_EXPOSE then
					_layer.taskDesc:setText(i3k_get_string(18219))
				else
					_layer.taskDesc:setText(i3k_get_string(18220))
				end
			end
		elseif taskId > 0 then
			local taskCfg = g_i3k_db.i3k_db_get_knightly_detective_task_cfg(taskId)
			_layer.taskDesc:setText(g_i3k_db.i3k_db_get_task_desc(taskCfg.type, taskCfg.arg1, taskCfg.arg2, 0, false, nil))
		end
	end
end
function wnd_battleTask:updateDetectiveTask()
	self:removeTaskItem(TASK_CATEGORY_DETECTIVE)
	local item, time = self:createDetectiveItem()
	self:updateItemPos(TASK_CATEGORY_DETECTIVE, item, time)
end
function wnd_battleTask:openDetectiveUI(sender)
	g_i3k_logic:OpenKnightlyDetectiveUI()
end
function wnd_battleTask:doDetectiveTask(sender, args)
	g_i3k_game_context:GoingToDoTask(args.type, args.cfg, nil)
end
function wnd_battleTask:removeDetectiveTask()
	g_i3k_game_context:removeTaskData(TASK_CATEGORY_DETECTIVE)
	self:removeTaskItem(TASK_CATEGORY_DETECTIVE)
	self:updateTaskInfo()
end
--------大侠朋友圈任务
function wnd_battleTask:createSwordsmanTask()
	local data = g_i3k_game_context:getSwordsmanCircleData()
	if data and data.curTaskId and data.curTaskId ~= 0 then
		local _layer = require(LAYER_RWLBT)()
		_layer.vars.time_label:hide()
		_layer.vars.effect1:hide()
		local taskCfg = i3k_db_swordsman_circle_tasks[data.curTaskId]
		local name = string.format("%s%s", taskCfg.prename, taskCfg.name)
		_layer.vars.taskName:setText(name)
		_layer.vars.task_btn:onClick(self, self.doSwordsmanTask, {type = TASK_CATEGORY_SWORDSMAN, id = data.curTaskId, cfg = taskCfg})
		_layer.vars.task_btn:setTag(TASK_CATEGORY_SWORDSMAN)
		return _layer
	end
end
function wnd_battleTask:updateSwordsmanTaskTag()
	if self._scrollItems[TASK_CATEGORY_SWORDSMAN] then
		local _layer = self._scrollItems[TASK_CATEGORY_SWORDSMAN].vars
		local taskId, value, state = g_i3k_game_context:getSwordsmanCircleTask()
		if (not taskId) or taskId == 0 then
			return
		end
		local taskCfg = i3k_db_swordsman_circle_tasks[taskId]
		local isFinish = g_i3k_game_context:IsTaskFinished(taskCfg.type, taskCfg.arg1, taskCfg.arg2, value)
		_layer.taskDesc:setText(self:getCommonTaskDesc(taskCfg, value, state, isFinish))
	end
end
function wnd_battleTask:udpateSwordsmanTask(isFinish)
	local layer = self._scrollItems[TASK_CATEGORY_SWORDSMAN]
	if isFinish ~= nil and layer then
		local taskId, value, state = g_i3k_game_context:getSwordsmanCircleTask()
		if (not taskId) or taskId == 0 then
			return
		end
		local cfg = i3k_db_swordsman_circle_tasks[taskId]
		layer.vars.taskDesc:setText(self:getCommonTaskDesc(cfg, value, state, isFinish))
		if isFinish then
			if layer.vars.effect1 then
				layer.vars.effect1:show()
			end
		end
		if isFinish and (cfg.type == g_TASK_NEW_NPC_DIALOGUE or cfg.type == g_TASK_USE_ITEM) then
			self:finishTask(cfg, TASK_CATEGORY_SWORDSMAN)
		end
	else
		self:removeFactionTaskItem(TASK_CATEGORY_SWORDSMAN)
		local taskItem = self:createSwordsmanTask()
		self:updateItemPos(TASK_CATEGORY_SWORDSMAN, taskItem)
	end
end
function wnd_battleTask:doSwordsmanTask(sender, args)
	local data = g_i3k_game_context:getSwordsmanCircleData()
	if data and data.taskStatus then
		self:doTask(args, data.taskStatus, data.curValue)
	end
end
--黄金海岸：赏金任务
function wnd_battleTask:createGlobalWorldTask()
	local data = g_i3k_game_context:GetGlobalWorldTaskData()
	if next(data) then
		local _layer = require(LAYER_RWLBT)()
		_layer.vars.time_label:hide()
		_layer.vars.effect1:hide()
		_layer.vars.taskName:setText(string.format("%s%s",i3k_get_string(5583),i3k_get_string(5584)))
		local num, maxNum = g_i3k_game_context:GetGlobalWorldTaskCompleteNum()
		_layer.vars.taskDesc:setText(i3k_get_string(5585, maxNum, num, maxNum))
		if num == maxNum then
			return nil
		end
		_layer.vars.task_btn:onClick(self, self.OnGlobalWorldTaskClick)
		_layer.vars.task_btn:setTag(TASK_CATEGORY_GLOBALWORLD)
		return _layer
	end
end
function wnd_battleTask:updateGlobalWorldTask()
	if self._scrollItems[TASK_CATEGORY_GLOBALWORLD] then
		local _layer = self._scrollItems[TASK_CATEGORY_GLOBALWORLD].vars
		local num, maxNum = g_i3k_game_context:GetGlobalWorldTaskCompleteNum()
		_layer.taskDesc:setText(i3k_get_string(5585, maxNum, num, maxNum))
	end
end
function wnd_battleTask:OnGlobalWorldTaskClick()
	g_i3k_ui_mgr:OpenUI(eUIID_Task)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Task,"initShangJinData")
end
--赏金任务end
function wnd_battleTask:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 1 then
		self:updateTaskGuideTime(dTime)
		self._timeCounter = 0
	end
end

function wnd_battleTask:updateTaskGuideTime(dTime)
	if not g_i3k_db.i3k_db_is_can_show_task_guide() then
		return
	end
	self._taskGuideTime = self._taskGuideTime + 1

	--新手登陆拍脸界面打开时 不显示箭头
	if g_i3k_ui_mgr:GetUI(eUIID_FirstLoginShow) then
		self:clearTaskGuideTimer()
		return
	end

	--任务界面处于任务界面
	if self._tabState ~= 1 then
		self:clearTaskGuideTimer()
		return
	end

	--任务界面是否展开
	if self._layout.vars.openBtn:isVisible() then
		self:clearTaskGuideTimer()
		return
	end

	--是否是对话状态
	if g_i3k_logic:isTalkUI() then
		self:clearTaskGuideTimer()
		return
	end

	--角色是否在行走或者攻击状态
	local hero = i3k_game_get_player_hero()
	if hero then
		if hero:IsPlayerMove() or hero:IsPlayerAttack() then
			self:clearTaskGuideTimer()
			return
		end
	end

	if self._taskGuideTime >= i3k_db_common.taskGuide.needSecond and not g_i3k_ui_mgr:GetUI(eUIID_TaskGuide) then
		self._taskGuideCo = g_i3k_coroutine_mgr:StartCoroutine(function ()
			g_i3k_coroutine_mgr.WaitForNextFrame()

			self._taskGuideTime = 0
			g_i3k_ui_mgr:OpenUI(eUIID_TaskGuide)

			g_i3k_coroutine_mgr:StopCoroutine(self._taskGuideCo)
			self._taskGuideCo = nil
		end)
	end
end

-- 每点击一次屏幕，关闭指引，重新计数
function wnd_battleTask:clearTaskGuideTimer()
	if self._taskGuideTime >= 1 then
		g_i3k_logic:CloseTaskGuideUI()
		self._taskGuideCo = nil
		self._taskGuideTime = 0
	end
end

-----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleTask.new();
		wnd:create(layout);
	return wnd;
end
