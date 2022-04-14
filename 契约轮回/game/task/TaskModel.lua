-- 
-- @Author: LaoY
-- @Date:   2018-09-05 20:59:59
-- 
TaskModel = TaskModel or class("TaskModel", BaseBagModel)
local this = TaskModel

TaskModel.NpcState = {
    Accept = 1, --可接
    UnFinished = 2, --已接未完成
    Finish = 3, --已完成未提交
}

TaskModel.BitState = {
    OpenUI = BitState.State[1],
}

function TaskModel:ctor()
    TaskModel.Instance = self
    self:Reset()
end

function TaskModel:Reset()
    self:StopFindNextTaskTime()
    self.last_task_id = 0
    self.next_task_id = -1
    self.task_list = {}

    self.last_guide_time = nil
    self.last_guide_task_id = nil
    self.last_guide_task_str = nil
    self.add_task_id_list = {}
    self.has_guide_list = {}

    self.task_bit_state = BitState()
    self.isOpenNpcPanel = false
    self:ResetGuideState()
end

function TaskModel:ResetGuideState()
    self.is_non_existent_main_task = false
end

function TaskModel.GetInstance()
    if TaskModel.Instance == nil then
        TaskModel()
    end
    return TaskModel.Instance
end

function TaskModel:AddTaskList(task_list)
    for i = 1, #task_list do
        local vo = task_list[i]
        self:AddTask(vo)
    end
end

function TaskModel:AddTask(vo)
    local config = Config.db_task[vo.id]
    if not vo.task_type then
        if not config then
            if AppConfig.Debug then
                logError("任务配置不存在，id是：", vo.id)
                return
            end
        else
            vo.rank = config.rank
            vo.task_type = config and config.type or enum.TASK_TYPE.TASK_TYPE_MAIN

        end
    end
    if vo.task_type ~= enum.TASK_TYPE.TASK_TYPE_DAILY and vo.task_type ~= enum.TASK_TYPE.TASK_TYPE_GUILD then
        vo.goals = String2Table(config.goals) or {}
    else
        vo.goals = {}
        for i = 1, #vo.goal do
            local goal = vo.goal[i]
            local findway = goal.findway and 1 or 0
            vo.goals[#vo.goals + 1] = { goal.event, goal.target, goal.amount, goal.scene, findway }
        end
    end
    local task = self.task_list[vo.id]
    if task and vo.state == enum.TASK_STATE.TASK_STATE_FINISH then
		task.state = enum.TASK_STATE.TASK_STATE_FINISH
        GlobalEvent:Brocast(TaskEvent.FinishTask, vo.id)
    end
    if not task then
        -- 某些任务引导需要停下来的
        -- 停止自动任务 停止自动战斗 停止自动寻路
        if self:IsInGuideStopTask(vo.id) then
            AutoTaskManager:GetInstance():CleanTaskInfo()
            AutoTaskManager:GetInstance():SetAutoTaskState(false)

            -- 
            OperationManager:GetInstance():StopAStarMove()
            AutoFightManager:GetInstance():StopAutoFight()
        end
    end
    self.task_list[vo.id] = vo
end

function TaskModel:DeleteTaskList(list)
    for k, id in pairs(list) do
        self:DeleteTask(id)
    end
end

function TaskModel:DeleteTask(id)
    local task = self.task_list[id]
    if task and task.task_type == enum.TASK_TYPE.TASK_TYPE_MAIN then
        self.last_task_id = id
        if self.next_task_id <= self.last_task_id then
            -- self.next_task_id = self.last_task_id + 1
            -- self.next_task_id = self:GetNextMainTaskID(self.last_task_id)
        end
        self.task_list[id] = nil
        GlobalEvent:Brocast(TaskEvent.FinishMainTask, id)
    end
    self.task_list[id] = nil
end

function TaskModel:GetNextMainTaskID(task_id)
    if not task_id then
        return task_id
    end
    local next_cf = Config.db_task[task_id + 1]
    if next_cf then
        return next_cf.id
    end
    next_cf = Config.db_task[task_id + 100]
    if next_cf then
        return next_cf.id
    end

    for k, v in pairs(Config.db_task) do
        if v.prev == task_id then
            return v.id
        end
    end
    return nil
end

--[[
	@author LaoY
	@des	是否完成任务(主线)
--]]
function TaskModel:IsFinishMainTask(task_id)
    if not task_id or task_id == 0 or self.next_task_id == 0 then
        return true
    end
    local main_task_id
    for k, v in pairs(self.task_list) do
        if v.task_type == enum.TASK_TYPE.TASK_TYPE_MAIN then
            main_task_id = v.id
            break
        end
    end
    main_task_id = main_task_id or self.next_task_id
    if not main_task_id then
        return false
    end
    return main_task_id > task_id
end

function TaskModel:DoNextTaskByType(task_type)
    if not self:IsSceneCanAutoTask() then
        return
    end
    task_type = task_type or enum.TASK_TYPE.TASK_TYPE_MAIN
    for k, task in pairs(self.task_list) do
        if task.task_type == task_type and (task.state == enum.TASK_STATE.TASK_STATE_TRIGGER or task.state == enum.TASK_STATE.TASK_STATE_ACCEPT) then
            self:AutoDotask(task.id)
            return
        end
    end
end

function TaskModel:DoTaskByType(task_type,is_fly,errCallBack)
    if not task_type then
        return
    end
    local check_task_type_list = {
        [enum.TASK_TYPE.TASK_TYPE_DAILY] = {enum.TASK_TYPE.TASK_TYPE_LOOP1,enum.TASK_TYPE.TASK_TYPE_PREV1},
        [enum.TASK_TYPE.TASK_TYPE_GUILD] = {enum.TASK_TYPE.TASK_TYPE_LOOP2,enum.TASK_TYPE.TASK_TYPE_PREV2},
		
        -- enum.TASK_TYPE.TASK_TYPE_LOOP3
		--[enum.TASK_TYPE.TASK_TYPE_PREV3] = {enum.TASK_TYPE.TASK_TYPE_BEAST,enum.TASK_TYPE.TASK_TYPE_LOOP3},
		--[enum.TASK_TYPE.TASK_TYPE_PREV4] = {enum.TASK_TYPE.TASK_TYPE_BEAST,enum.TASK_TYPE.TASK_TYPE_LOOP4},
    }

    local task_id = self:GetTaskIdByType(task_type)
    if task_id then
        self:DoTask(task_id,is_fly,errCallBack)
        return
    end

    if check_task_type_list[task_type] then
        for k,_task_type in ipairs(check_task_type_list[task_type]) do
            local _task_id = self:GetTaskIdByType(_task_type)
            if _task_id then
                self:DoTask(_task_id,is_fly,errCallBack)
                return
            end
        end
    end
end

function TaskModel:GetTaskIdByType(task_type)
    local check_task_type_list = {
        [enum.TASK_TYPE.TASK_TYPE_DAILY] = function(task_type) return 
                    task_type == enum.TASK_TYPE.TASK_TYPE_DAILY or task_type == enum.TASK_TYPE.TASK_TYPE_LOOP1 or task_type == enum.TASK_TYPE.TASK_TYPE_PREV1 
                end,
        [enum.TASK_TYPE.TASK_TYPE_GUILD] = function(task_type) return 
                    task_type == enum.TASK_TYPE.TASK_TYPE_GUILD or task_type == enum.TASK_TYPE.TASK_TYPE_LOOP2 or task_type == enum.TASK_TYPE.TASK_TYPE_PREV2 
                end,
    }

    local task_id
    for k, task in pairs(self.task_list) do
        if task.task_type == task_type then
            return task.id
        elseif not task_id and check_task_type_list[task_type] and check_task_type_list[task_type](task.task_type) then
            task_id = task.id
        end
    end
    return task_id
end

function TaskModel:GetMainShowTaskList()
    local list = {}
    local is_have_main_task = false
    local rein_list = {}
    local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
    for k, v in table.pairsByKey(self.task_list) do
        -- 转生任务和跑环任务不显示
        -- 跑环任务的实际内容在日常任务
        -- if v.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP1 and v.state == enum.TASK_STATE.TASK_STATE_FINISH then
        -- 	print("--------------------")
        -- end
        if v.id ~= 10000 then
            local config = Config.db_task[v.id]
            if config.panel_show == 1 and v.task_type == enum.TASK_TYPE.TASK_TYPE_REIN then
                local goal_type = v.goals[1] or {}
                goal_type = goal_type[1]
                if config.minlv <= lv and v.state ~= enum.TASK_STATE.TASK_STATE_TRIGGER and goal_type ~= enum.EVENT.EVENT_WAKE then
                    rein_list[#rein_list + 1] = v
                end
            elseif config.panel_show == 1 and not (v.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP1 and v.state ~= enum.TASK_STATE.TASK_STATE_FINISH) and
                    not (v.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP2 and v.state ~= enum.TASK_STATE.TASK_STATE_FINISH) and
                    not (v.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP3 and v.state ~= enum.TASK_STATE.TASK_STATE_FINISH) and
                    not (v.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP4 and v.state ~= enum.TASK_STATE.TASK_STATE_FINISH) then
                list[#list + 1] = v
            end
            if not is_have_main_task and v.task_type == enum.TASK_TYPE.TASK_TYPE_MAIN then
                is_have_main_task = true
            end
        end
    end
    if not is_have_main_task then
        self.is_non_existent_main_task = true
        local config = Config.db_task[self.next_task_id]
        if config then
            local task = {
                id = config.id,
                prog = 0,
                count = 0,
                state = enum.TASK_STATE.TASK_STATE_COMING,
                etime = 0,
                task_type = enum.TASK_TYPE.TASK_TYPE_MAIN,
                rank = 8,
                goals = String2Table(config.goals) or {},
            }
            list[#list + 1] = task
        end
    end


    local rein_task_count = WakeModel:GetInstance():GetShowTaskNum()
    if #rein_list > rein_task_count then
        local function sortFunc(a,b)
            return a.id < b.id
        end
        table.sort(rein_list,sortFunc)
    end
    table.insertarray(list, rein_list, rein_task_count)

    local function sortFunc(task1, task2)
        local is_main_task1 = task1.task_type == enum.TASK_TYPE.TASK_TYPE_MAIN and task1.state ~= enum.TASK_STATE.TASK_STATE_COMING
        local is_main_task2 = task2.task_type == enum.TASK_TYPE.TASK_TYPE_MAIN and task2.state ~= enum.TASK_STATE.TASK_STATE_COMING
        is_main_task1 = toBool(is_main_task1)
        is_main_task2 = toBool(is_main_task2)
        if is_main_task1 ~= is_main_task2 then
            return is_main_task1
        end

        local is_finish_1 = task1.state == enum.TASK_STATE.TASK_STATE_FINISH
        local is_finish_2 = task2.state == enum.TASK_STATE.TASK_STATE_FINISH
        if is_finish_1 == is_finish_2 then
            if task1.rank == task2.rank then
                local is_neew_1 = self.add_task_id_list[task1.id]
                is_neew_1 = toBool(is_neew_1)
                local is_neew_2 = self.add_task_id_list[task2.id]
                is_neew_2 = toBool(is_neew_2)

                if is_neew_1 == is_neew_2 then
                    return task1.id < task2.id
                else
                    return is_neew_1
                end
            else
                return task1.rank < task2.rank
            end
        else
            return is_finish_1
        end
    end
    table.sort(list, sortFunc)

    -- local quality, escort_name = FactionEscortModel:GetInstance():GetEscQua()
    -- local npc_id = FactionEscortModel:GetInstance():GetNpc()
    -- if escort_name and npc_id then
    --     local t = {
    --         "普通", "稀有", "豪华", "超神",
    --     }
    --     local type_name = enumName.TASK_TYPE[enum.TASK_TYPE.TASK_TYPE_ESCORT]
    --     local color = "ffe25a"
    --     local title = string.format("<color=#%s>[%s]%s(%s)</color>", color, type_name, escort_name, t[quality] or t[1])
    --     local npc_cf = Config.db_npc[npc_id]
    --     local des = string.format("护送到<color=#53f057>%s</color>", npc_cf.name or "护送NPC")
    --     local task = {
    --         id = -1,
    --         prog = 0,
    --         count = 0,
    --         state = nil,
    --         etime = 0,
    --         task_type = enum.TASK_TYPE.TASK_TYPE_ESCORT,
    --         rank = nil,
    --         goals = nil,
    --         title = title,
    --         des = des,
    --     }
    --     table.insert(list, 1, task)
    -- end

    return list
end

function TaskModel:GetLoopDaily()
    for k, v in table.pairsByKey(self.task_list) do
        -- 转生任务和跑环任务不显示
        -- 跑环任务的实际内容在日常任务
        if v.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP1 then
            return v
        end
    end
end

function TaskModel:GetLoopGuild()
    for k, v in table.pairsByKey(self.task_list) do
        -- 转生任务和跑环任务不显示
        -- 帮派跑环任务的实际内容在公会任务
        if v.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP2 then
            return v
        end
    end
end

--[[
	@author LaoY
	@des	寻找下一个任务
--]]
function TaskModel:FindNextTask(id)
    -- 暂停任务
    -- 在副本中不自动任务
    if self.is_pause or not self:IsSceneCanAutoTask() then
        return
    end
    local auto_task_info = AutoTaskManager:GetInstance():GetTaskInfo()
    if table.isempty(auto_task_info) then
        return
    end

    -- 支线不继续任务
    -- 觉醒任务不继续任务
    local config = Config.db_task[auto_task_info.task_id]
    if config.type == enum.TASK_TYPE.TASK_TYPE_SIDE or config.type == enum.TASK_TYPE.TASK_TYPE_REIN then
        return
    end

    if id and auto_task_info.task_id ~= id then
        return
    end
    self:StopFindNextTaskTime()
    if auto_task_info.task_type == enum.TASK_TYPE.TASK_TYPE_DAILY then
        local cur_main_task_id = TaskModel:GetInstance():GetTaskIdByType(enum.TASK_TYPE.TASK_TYPE_MAIN)
        if cur_main_task_id and auto_task_info.main_task_id ~= cur_main_task_id then
            self:DoTask(cur_main_task_id)
            return
        end
    end
    local data = self.task_list[auto_task_info.task_id]
    if data then
        if (data.task_type == enum.TASK_TYPE.TASK_TYPE_DAILY or data.task_type == enum.TASK_TYPE.TASK_TYPE_GUILD) then
            -- Yzprint('--LaoY TaskModel.lua,line 193--')
            -- Yzdump(data,"data")
            if data.state ~= enum.TASK_STATE.TASK_STATE_FINISH then
                if auto_task_info.goal_type ~= enum.EVENT.EVENT_CREEP or data.count == 0 then
                    self:DoTask(auto_task_info.task_id)
                end
            end
            return
        elseif data.prog == auto_task_info.prog then
            -- if auto_task_info.goal_type ~= enum.EVENT.EVENT_CREEP then
            -- 	self:DoTask(auto_task_info.task_id)
            -- end
            self:DoTask(auto_task_info.task_id)
            return
        elseif data.state ~= enum.TASK_STATE.TASK_STATE_FINISH then
            self:DoTask(auto_task_info.task_id)
            return
        elseif data.state == enum.TASK_STATE.TASK_STATE_FINISH then
            -- self:Brocast(TaskEvent.ReqTaskSubmit,auto_task_info.task_id)
            return
        end
    else
        if auto_task_info.task_type == enum.TASK_TYPE.TASK_TYPE_MAIN then
            local cur_main_task_id = TaskModel:GetInstance():GetTaskIdByType(enum.TASK_TYPE.TASK_TYPE_MAIN)
            if cur_main_task_id then
                self:DoTask(cur_main_task_id)
                return
            end
            local daily_task_id = TaskModel:GetInstance():GetTaskIdByType(enum.TASK_TYPE.TASK_TYPE_DAILY)
            if daily_task_id then
                self:DoTask(daily_task_id)
                return
            end
        end
        local daily_loop_pb = self:GetLoopDaily()
        if daily_loop_pb and daily_loop_pb.state == enum.TASK_STATE.TASK_STATE_FINISH then
            self:FinishTask(daily_loop_pb.id)
            return
        end

        local guild_loop_pb = self:GetLoopGuild()
        if guild_loop_pb and guild_loop_pb.state == enum.TASK_STATE.TASK_STATE_FINISH then
            self:FinishTask(guild_loop_pb.id)
            return
        end

        local last_auto_task_id = AutoTaskManager:GetInstance():GetLastTaskID()
        local task_type = enum.TASK_TYPE.TASK_TYPE_MAIN
        if last_auto_task_id then
            local config = Config.db_task[last_auto_task_id]
            task_type = config.type
            if task_type == enum.TASK_TYPE.TASK_TYPE_PREV1 then
                task_type = enum.TASK_TYPE.TASK_TYPE_DAILY
            elseif task_type == enum.TASK_TYPE.TASK_TYPE_PREV2 then
                task_type = enum.TASK_TYPE.TASK_TYPE_GUILD
            end
        end

        local task_list = self:GetMainShowTaskList()
        if not table.isempty(task_list) then
            for i, task in ipairs(task_list) do
                local config = Config.db_task[task.id]
                if not config and AppConfig.Debug then
                    logError('----任务配置不存在，id是：',task.id)
                end
                if config and config.type == task_type and
                        (task.state == enum.TASK_STATE.TASK_STATE_TRIGGER or task.state == enum.TASK_STATE.TASK_STATE_ACCEPT) then
                    self:AutoDotask(task.id)
                    return
                end
            end
        end

        if task_type == enum.TASK_TYPE.TASK_TYPE_DAILY and server_pb and server_pb.state ~= enum.TASK_STATE.TASK_STATE_FINISH then
            return
            -- 公会任务
            -- elseif task_type == enum.TASK_TYPE.TASK_TYPE_DAILY and server_pb and server_pb.state ~= enum.TASK_STATE.TASK_STATE_FINISH then
        end

        if not last_auto_task_id then
            return
        end

        -- 到离这里没找到可以继续的任务，清掉记录
        AutoTaskManager:GetInstance().last_task_id = nil
        if task_type ~= enum.TASK_STATE.TASK_TYPE_MAIN then
            self:FindNextTask()
            return
        end
    end
    self:StopTask()
    return
end

function TaskModel:StopFindNextTaskTime()
    if self.auto_find_next_time_id then
        GlobalSchedule:Stop(self.auto_find_next_time_id)
        self.auto_find_next_time_id = nil
    end
end

-- 除了dotask，其他点击操作任务走这里
function TaskModel:OperateTask(task_id)
    -- self:StopFindNextTaskTime()
    -- self:StopAutoDoMainTask()

	local config = Config.db_task[task_id]
	if config and config.type == enum.TASK_TYPE.TASK_TYPE_SIDE then
		return
	end
    local auto_task_info = AutoTaskManager:GetInstance():GetTaskInfo()
    local bo = true
    if not table.isempty(auto_task_info) then
        local config = Config.db_task[auto_task_info.task_id]
		if config and config.type ~= enum.TASK_TYPE.TASK_TYPE_SIDE then
			return
		end
    end
    
    AutoTaskManager:GetInstance():SetAutoTaskState(true)
    AutoTaskManager:GetInstance():SetTaskInfo(task_id, 0, 0, 0)
    AutoTaskManager:GetInstance():SetLastOperateTime()
end

function TaskModel:FinishTask(task_id)
    self:OperateTask(task_id)

    local config = Config.db_task[task_id]
    if config.type == enum.TASK_TYPE.TASK_TYPE_LOOP1 then
        GlobalEvent:Brocast(MainEvent.OpenTaskReward, task_id)
    else
        self:Brocast(TaskEvent.ReqTaskSubmit, task_id)
    end
end

--[[
	@author LaoY
	@des	是否为任务NPC
--]]
function TaskModel:IsTaskNpc(npc_id)
    return true
end

function TaskModel:GetTaskInfoByNpc(npc_id)
    local auto_info = AutoTaskManager:GetInstance():GetTaskInfo()
    if auto_info then
        local info = self:GetNpcTaskInfo(auto_info.task_id, npc_id)
        if info then
            return info
        end
    end
    for k, v in pairs(self.task_list) do
        local info = self:GetNpcTaskInfo(v.id, npc_id)
        if info then
            return info
        end
    end
    return nil
end

function TaskModel:GetNpcTaskInfo(task_id, npc_id)
    local task_config = Config.db_task[task_id]
    if task_config then
        local task = self.task_list[task_id]
        -- local goals = String2Table(task_config.goals) or {}
        if not task then
            return nil
        end
        local goals = task.goals
        local cur_goal = goals[task.prog + 1]
        local start_index = task.prog + 1
        if task.task_type == enum.TASK_TYPE.TASK_TYPE_DAILY or task.task_type == enum.TASK_TYPE.TASK_TYPE_GUILD then
            cur_goal = goals[1]
            start_index = 1
        end
        local talk_index = 0
        local npc_prog
        if cur_goal and cur_goal[2] == npc_id then
            npc_prog = task.prog + 1
        else
            local new_prog
            for i = start_index, #goals do
                local goal = goals[i]
                if goal[2] == npc_id then
                    new_prog = prog
                end
                if new_prog and new_prog > task.prog + 1 then
                    break
                end
            end
            npc_prog = new_prog
        end

        if npc_prog then
            for i = 1, npc_prog do
                local goal = goals[i]
                if goal and goal[1] == enum.EVENT.EVENT_TALK then
                    talk_index = talk_index + 1
                end
            end
            return { task_id = task.id, config_prog = npc_prog, talk_index = talk_index, config = task_config }
        end
    end
    return nil
end

function TaskModel:GetNpcState(npc_id)
    if table.isempty(self.task_list) then
        return
    end
    for k, v in table.pairsByKey(self.task_list) do
        local task_config = Config.db_task[v.id]
        if task_config then
            -- local goals = String2Table(task_config.goals) or {}
            local goals = v.goals
            local cur_goal = goals[v.prog + 1]
            local talk_index = 0
            local npc_prog
            if cur_goal and cur_goal[2] == npc_id then
                return v.state
            else
                local next_goal = goals[v.prog + 2]
                if next_goal and next_goal[2] == npc_id then
                    return enum.TASK_STATE.TASK_STATE_TRIGGER
                end
            end
        end
    end
    return nil
end

--[[
	@author LaoY
	@des	点击npc，检查npc是否有任务戏份
	@param1 npc_id
--]]
function TaskModel:OnTask(npc_id, call_back)
    if not self:IsTaskNpc(npc_id) then
        return false
    end
    local info = self:GetTaskInfoByNpc(npc_id)
    if not info then
        return false
    end
    local function btn_func()
        GlobalEvent:Brocast(SceneEvent.RequestTalk, npc_id, info.task_id)
        if call_back then
            call_back()
        end
    end

    local talk_config = String2Table(info.config.talk)
    local content = talk_config[info.talk_index] and talk_config[info.talk_index]
    if type(content) == "table" then
       -- call_back = btn_func2
        GlobalEvent:Brocast(MainEvent.OpenTaskTalk, info.task_id, info.config_prog, talk_config, btn_func)
        return true
    end
    GlobalEvent:Brocast(MainEvent.OpenTaskTalk, info.task_id, info.config_prog, content, btn_func)
    return true
end

function TaskModel:GetTaskProg(task_id)
    local task = self.task_list[task_id]
    return task and task.prog
end

function TaskModel:GetTask(task_id)
    return self.task_list[task_id]
end

-- 自动做下一个任务，主线任务需要延时处理
function TaskModel:AutoDotask(task_id)
    local task = self.task_list[task_id]
    if not task then
        return
    end
    if self.last_auto_task_id == task_id then
        return
    end
    Yzprint('--LaoY TaskModel.lua,line 524--', self.last_auto_task_id, task_id, self.auto_do_main_task_time_id)
    self.last_auto_task_id = task_id
    self:StopAutoDoMainTask()
    if task.task_type == enum.TASK_TYPE.TASK_TYPE_MAIN then
        local function step()
            self.last_auto_task_id = nil
            if not self:IsSceneCanAutoTask() then
                self:StopAutoDoMainTask()
                return
            end
            self:DoTask(task_id)
        end
        self.auto_do_main_task_time_id = GlobalSchedule:StartOnce(step, 0.5)
    else
        self:DoTask(task_id)
    end
end

function TaskModel:IsSceneCanAutoTask()
    return not (DungeonModel:GetInstance():IsDungeonScene() or 
        ArenaModel:GetInstance():IsArenaFight())
end

function TaskModel:StopAutoDoMainTask()
    if self.auto_do_main_task_time_id then
        GlobalSchedule:Stop(self.auto_do_main_task_time_id)
        self.auto_do_main_task_time_id = nil
    end
end

--[[
	@author LaoY
	@des	做任务,执行寻路等
	@param1 param1
--]]
function TaskModel:DoTask(task_id, is_fly,errCallBack)
    self:StopFindNextTaskTime()
    self:StopAutoDoMainTask()
    self.last_auto_task_id = nil

    AutoTaskManager:GetInstance():CleanTaskInfo()
    self.is_pause = false
    self:StopTask()
    Yzprint('--LaoY TaskModel.lua,line 526--',task_id,self.task_list[task_id],Config.db_task[task_id])
    if not self.task_list[task_id] or not Config.db_task[task_id] then
        return
    end
    local data = self.task_list[task_id]
    if data and data.state == enum.TASK_STATE.TASK_STATE_FINISH then
        self:FinishTask(task_id)
        return
    end
    Yzdump(data, "data")
    local config = Config.db_task[task_id]
    -- local goals = String2Table(config.goals) or {}
    local goals = data.goals
    local cur_goal = goals[data.prog + 1]

    if data.task_type == enum.TASK_TYPE.TASK_TYPE_DAILY or data.task_type == enum.TASK_TYPE.TASK_TYPE_GUILD then
        cur_goal = goals[1]
    end

    if data.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP3 or data.task_type == enum.TASK_TYPE.TASK_TYPE_PREV3 or
    data.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP4 or data.task_type == enum.TASK_TYPE.TASK_TYPE_PREV4 or 
    data.task_type == enum.TASK_TYPE.TASK_TYPE_BEAST then
        cur_goal = goals[1]
    end

    if not cur_goal then
        return
    end
    self:Brocast(TaskEvent.DoTask,task_id)
    
    local goal_type = cur_goal[1]
    local target_id = cur_goal[2]
    local target_count = cur_goal[3]
    local target_scene_id = cur_goal[4]
    if target_scene_id == 0 then
        target_scene_id = SceneManager:GetInstance():GetSceneId()
    end
    local target_pos = nil
    local is_find_way = cur_goal[5] == 1
    local params = cur_goal[6]
    local callback
    local fin_way_range
    local main_role = SceneManager:GetInstance():GetMainRole()
    local link
    local fly_pos
	
	if data.task_type == enum.TASK_TYPE.TASK_TYPE_BEAST then
		local prev_task_id3 = self:GetTaskIdByType(enum.TASK_TYPE.TASK_TYPE_LOOP3)
		local prev_task_vo2 = self.task_list[prev_task_id3]
		
		local prev_task_id4 = self:GetTaskIdByType(enum.TASK_TYPE.TASK_TYPE_LOOP4)
		local prev_task_vo4 = self.task_list[prev_task_id4]
		
		if not prev_task_id3 and not prev_task_id4 then
			return
		end
		if prev_task_id3 then
			if not DungeonModel:GetInstance():IsBeastScene() then
				OpenLink(160,1,1,13,20401202)
				return
			end
		else
			if not DungeonModel:GetInstance():IsCrossBeastScene() then
				OpenLink(160,1,1,12,20501202)
				return
			end
		end

        -- 非对话任务 不自动。必须手动寻找
        if goal_type ~= enum.EVENT.EVENT_TALK then
            if errCallBack then
                errCallBack(target_id)
            end
            return
        end
	end
	
    if params then
        for k, v in pairs(params) do
            if v[1] == "link" then
                local len = #v
                link = {}
                for i = 2, len do
                    link[#link + 1] = v[i]
                end
            end
        end
    end
    if not table.isempty(link) then
        OpenLink(unpack(link))
    elseif goal_type == enum.EVENT.EVENT_LEVEL then

    elseif goal_type == enum.EVENT.EVENT_ITEM then
        if not is_fly or not DailyModel.GetInstance():FlyCurHookPos() then
            DailyModel:GetInstance():GoCurHookPos()
        end
        -- 对话任务
    elseif goal_type == enum.EVENT.EVENT_TALK then
        callback = function()
            -- AutoTaskManager:GetInstance():SetAutoTaskState(true)
            AutoTaskManager:GetInstance():DoTalk(task_id, target_id)
        end
        local pos = SceneConfigManager:GetInstance():GetNpcPosition(target_scene_id, target_id)
        fly_pos = SceneConfigManager:GetInstance():GetNPCFlyPos(target_id)
        Yzprint('--LaoY TaskModel.lua,line 616--', fly_pos)
        Yzdump(fly_pos, "fly_pos")
        if pos then
            target_pos = pos
        end
        -- 同场景、靠近任务点 都找不到npc
        if target_scene_id == SceneManager:GetInstance():GetSceneId() then
            local object = SceneManager:GetInstance():GetObject(target_id)
            if not object and target_pos and Vector2.Distance(target_pos, main_role:GetPosition()) < 300 then
                self:StopTask()
                return
            end
            -- if object then
            -- 	target_pos= GetDirDistancePostion(main_role:GetPosition(),object:GetPosition(),nil,SceneConstant.NPCRange*0.5)
            -- end
        end
        fin_way_range = SceneConstant.NPCRange

        -- 打怪
    elseif goal_type == enum.EVENT.EVENT_CREEP then
        local task_target = Config.db_creep[target_id]
        if target_id == 3 then
            local level
            local boss_type
            if params then
                for k, v in pairs(params) do
                    if v[1] == "level" then
                        level = v[2]
                    elseif v[1] == "boss_type" then
                        boss_type = v[2]
                    end
                end
            end
            -- 需要根据等级获取蛮荒boss的id
            local link_target_id
            if boss_type and level then
                link_target_id = DungeonModel:GetInstance():GetBossIDByTypeLevel(boss_type, level)
            end
            UnpackLinkConfig('160@1@' .. boss_type .. '@' .. link_target_id)
        elseif task_target and task_target.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS then
            UnpackLinkConfig('160@1@1@' .. target_id)
        else

            local pos = SceneConfigManager:GetInstance():GetCreepPosition(target_scene_id, target_id)
            if pos then
                target_pos = pos
            else
                if errCallBack then
                    errCallBack(target_id)
                end
            end
            if target_scene_id == SceneManager:GetInstance():GetSceneId() then
                -- local object = SceneManager:GetInstance():GetCreepByTypeId(target_id)
                -- if object then
                -- 	target_pos = GetDirDistancePostion(main_role:GetPosition(),object:GetPosition())
                -- end
            end

            callback = function()
                local object = SceneManager:GetInstance():GetCreepByTypeId(target_id, nil, nil, target_pos)
                if object then
                    SceneManager:GetInstance():LockCreep(object.object_info.uid)
                end
                -- AutoTaskManager:GetInstance():SetAutoTaskState(true)
            end

            local cf = Config.db_creep[target_id]
            if cf then
                local error_range = SceneConstant.RushDis + cf.volume * 0.5 + SceneConstant.AttactDis
                -- if cf.rarity == enum.CREEP_RARITY.CREEP_RARITY_COMM then
                --     error_range = 0
                -- end
                fin_way_range = error_range
            else
                fin_way_range = SceneConstant.MonsterRange
            end
        end
        -- 副本
        -- 通关副本一层
        -- 进入副本
    elseif goal_type == enum.EVENT.EVENT_DUNGE or
            goal_type == enum.EVENT.EVENT_DUNGE_FLOOR or
            goal_type == enum.EVENT.EVENT_DUNGE_ENTER then
        -- AutoTaskManager:GetInstance():SetAutoTaskState(true)
        is_find_way = false
        local dungeon_stype = target_id
        local is_enter_dungeon = false
        local dungeon_param = {task_id = task_id}
        if params then
            for k, v in pairs(params) do
                if v[1] == "dunge" then
                    DungeonCtrl:GetInstance():RequestEnterDungeon(nil, nil, v[2],nil,nil,dungeon_param)
                    is_enter_dungeon = true
                    break
                end
            end
        end
        if not is_enter_dungeon then
            DungeonModel:GetInstance():DoDungeonTask(dungeon_stype,dungeon_param)
        end

        -- 采集
    elseif goal_type == enum.EVENT.EVENT_COLLECT then
        callback = function()
            -- Yzprint('--LaoY TaskModel.lua,line 113-- data=',data)
            -- AutoTaskManager:GetInstance():SetAutoTaskState(true)
            AutoTaskManager:GetInstance():DoCollect(task_id, target_id)
        end
        Yzprint('--LaoY TaskModel.lua,line 628--', target_id)
        local pos = SceneConfigManager:GetInstance():GetCreepPosition(target_scene_id, target_id)
        if pos then
            target_pos = pos
        end
        -- 同场景、靠近任务点 都找不到采集物
        if target_scene_id == SceneManager:GetInstance():GetSceneId() then
            local object = SceneManager:GetInstance():GetCreepByTypeId(target_id)
            if not object and target_pos and Vector2.Distance(target_pos, main_role:GetPosition()) < 300 then
                self:StopTask()
                return
            end
            if object then
                target_pos = object:GetPosition()
            end
        end
        fin_way_range = SceneConstant.PickUpDis
        -- 装备
    elseif goal_type == enum.EVENT.EVENT_EQUIP then

    end
    AutoTaskManager:GetInstance():SetAutoTaskState(true)
    AutoTaskManager:GetInstance():SetTaskInfo(task_id, data.prog, target_id, goal_type)
    AutoTaskManager:GetInstance():SetLastOperateTime()

    AutoTaskManager:GetInstance():SetLastOperateTaskTime()

    if is_find_way and target_pos then
        fin_way_range = fin_way_range or 1

        -- Notify.ShowText(tostring(Vector2.Distance(main_role:GetPosition(), target_pos) > fin_way_range))

        if is_fly and (fly_pos or Vector2.Distance(main_role:GetPosition(), target_pos) > fin_way_range) then
        -- if is_fly and (Vector2.Distance(main_role:GetPosition(), target_pos) > fin_way_range) then
            if fly_pos then
                SceneControler:GetInstance():UseFlyShoeToPos(target_scene_id, fly_pos.x, fly_pos.y, nil, callback)
            else
                SceneControler:GetInstance():UseFlyShoeToPos(target_scene_id, target_pos.x, target_pos.y, nil, callback)
            end
            return
        end
        self:FindTarget(target_scene_id, target_pos, callback, fin_way_range, fly_pos)
    end
end

--[[
	@author LaoY
	@des	
	@param1 fin_way_range 距离目标点多少范围算是到达目的地
--]]
function TaskModel:FindTarget(target_scene_id, target_pos, callback, fin_way_range, fly_pos)
    local main_role = SceneManager:GetInstance():GetMainRole()
    local start_pos = main_role:GetPosition()
    if target_pos then
        AutoTaskManager:GetInstance():SetAStarInfo(target_scene_id,target_pos)
    end
    OperationManager:GetInstance():CheckMoveToPosition(target_scene_id, start_pos, target_pos, callback, fin_way_range, nil, nil, nil, fly_pos)
end

function TaskModel:StopTask()
    -- AutoTaskManager:GetInstance():CleanTaskInfo()
    AutoTaskManager:GetInstance():SetAutoTaskState(false)
end

function TaskModel:OpenUIChangeBitState(is_open)
    -- TaskModel.BitState.OpenUI
    local auto_task_info = AutoTaskManager:GetInstance():GetTaskInfo()
    if table.isempty(auto_task_info) then
        self.task_bit_state:Remove(TaskModel.BitState.OpenUI)
        return
    end
    local config = Config.db_task[auto_task_info.task_id]
    if config.type ~= enum.TASK_TYPE.TASK_TYPE_MAIN then
        self.task_bit_state:Remove(TaskModel.BitState.OpenUI)
        return
    end

    if is_open then
        if AutoTaskManager:GetInstance():IsTaskAStar() then
            self:SetTaskBitState(TaskModel.BitState.OpenUI,is_open)
        end
    else
        if self.task_bit_state:Contain(TaskModel.BitState.OpenUI) and not GuideModel:GetInstance():HasGuide() and (not OperationManager:GetInstance():IsAutoWay() or AutoTaskManager:GetInstance():IsTaskAStar()) then
            self:SetTaskBitState(TaskModel.BitState.OpenUI,is_open)
        else
            self.task_bit_state:Remove(TaskModel.BitState.OpenUI)
        end
    end
end

function TaskModel:SetTaskBitState(state,is_add)
    local last_bo = self.task_bit_state:Contain()
    if is_add then
        self.task_bit_state:Add(state)
    else
        self.task_bit_state:Remove(state)
    end

    local bo = self.task_bit_state:Contain()
    if last_bo == bo then
        return
    end
    if bo then
        self:PauseTask(true)
    else
        self:ResumeTask(true)
    end
end

function TaskModel:PauseTask(isStopAstar)
    isStopAstar = isStopAstar == nil and true or isStopAstar
    self:StopAutoDoMainTask()
    self.last_auto_task_id = nil
    self.is_pause = true
    AutoTaskManager:GetInstance():SetAutoTaskState(false)
    if isStopAstar then
        OperationManager:GetInstance():StopAStarMove()
    end
end

function TaskModel:ResumeTask(force)
    self.is_pause = false
    AutoTaskManager:GetInstance():SetAutoTaskState(true)
    local auto_task_info = AutoTaskManager:GetInstance():GetTaskInfo()
    if table.isempty(auto_task_info) then
        if not force then
            return
        end
        -- 找主线任务继续用
        self:DoNextTaskByType()
    else
        self:FindNextTask()
    end
end

function TaskModel:EnterDungeon()
    self.enter_auto_state = AutoTaskManager:GetInstance():GetAutoTaskState()
end

function TaskModel:SetDungeonTaskState(flag)
    self.enter_auto_state = flag
end

function TaskModel:LeaveDungeon()
    if self.enter_auto_state then
        self:StopFindNextTaskTime()
        local function step()
            if not LoadingCtrl:GetInstance().loadingPanel then
                self:FindNextTask()
                self:StopFindNextTaskTime()
            end
        end
        self.auto_find_next_time_id = GlobalSchedule:Start(step, 1.0)
    end
end

function TaskModel:GetLoopReward(type, level)
    level = level or RoleInfoModel:GetInstance():GetRoleValue("level")
    for k, v in pairs(Config.db_task_loop) do
        if type == v.type then
            if level >= v.minlv and level <= v.maxlv then
                return v
            end
        end
    end
    return nil
end

function TaskModel:GetGuideTaskID(list)
    -- 主线的任务配置的指引没有做，不继续其他
    if self:IsMainTaskGuide(self.last_guide_task_id) then
        return self.last_guide_task_id, self.last_guide_task_str
    end
    if not self:IsSpecialGuide(self.last_guide_task_id) and self.last_guide_time and Time.time - self.last_guide_time < GuideItem4.ShowTime then
        if self.last_guide_task_id and self.task_list[self.last_guide_task_id] then
            return self.last_guide_task_id, self.last_guide_task_str
        end
    end

    -- Yzprint('--LaoY TaskModel.lua,line 737--')
    -- Yzdump(self.add_task_id_list,"self.add_task_id_list")
    -- Yzdump(list,"list")

    local guide_task_id = nil
    local guide_task_str = ""

    -- if not guide_task_id then
    --     for k, v in pairs(list) do
    --         if not self.has_guide_list[v.id] then
    --             if v.task_type == enum.TASK_TYPE.TASK_TYPE_MAIN then
    --                 local cf = Config.db_task[v.id]
    --                 if cf and not string.isempty(cf.new) then
    --                     guide_task_id = v.id
    --                     guide_task_str = cf.new
    --                     break
    --                 elseif self.is_non_existent_main_task and v.state ~= enum.TASK_STATE.TASK_STATE_COMING then
    --                     guide_task_id = v.id
    --                     guide_task_str = "请继续做主线任务哦"
    --                     break
    --                 end
    --             elseif v.task_type == enum.TASK_TYPE.TASK_TYPE_SIDE and self.add_task_id_list[v.id] then
    --                 local cf = Config.db_task[v.id]
    --                 if not string.isempty(cf.new) then
    --                     guide_task_id = v.id
    --                     guide_task_str = cf.new
    --                     break
    --                 end
    --             elseif not self.is_guide_loop1 and v.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP1 and self.add_task_id_list[v.id] then
    --                 guide_task_id = v.id
    --                 -- guide_task_str = "完成日常任务快速升级哦"
    --                 guide_task_str = "完成日常任务升级快"
    --                 self.is_guide_loop1 = true
    --                 break
    --             end
    --         end
    --     end
    -- end
    local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
    local len = #list
    for i=1,len do
        local v = list[i]
        if not self.has_guide_list[v.id] then
            local cf = Config.db_task[v.id]
            if cf and not string.isempty(cf.new) and lv >= cf.minlv then
                guide_task_id = v.id
                guide_task_str = cf.new
                self.is_special_guide = false
                break
            end
        end
    end

    -- 以上指引只需要出现一次
    if guide_task_id then
        self.has_guide_list[guide_task_id] = true
    end

    -- b：有支线任务奖励可以直接领取
    if not guide_task_id then
        for i=1,len do
            local v = list[i]
            if v.task_type == enum.TASK_TYPE.TASK_TYPE_SIDE and v.state == enum.TASK_STATE.TASK_STATE_FINISH then
                guide_task_id = v.id
                guide_task_str = "Quest rewards are available"
                self.is_special_guide = true
                break
            end
        end
    end

    -- c:主线任务
    if not guide_task_id and not self.is_non_existent_main_task and lv <= 230 and AutoTaskManager:GetInstance():IsCanAutoGuide(GuideItem4.AutoMaintaskTip) then
        for i=1,len do
            local v = list[i]
            if v.task_type == enum.TASK_TYPE.TASK_TYPE_MAIN then
                guide_task_id = v.id
                guide_task_str = "Continue your adventure"
                self.is_special_guide = true
                break
            end
        end
    end

    -- d 活跃任务在第一位
    if not guide_task_id and AutoTaskManager:GetInstance():IsCanAutoGuide(GuideItem4.AutoActiveTaskTip) then
        local v = list[1]
        if v and v.task_type == enum.TASK_TYPE.TASK_TYPE_ACTIVE then
            guide_task_id = v.id
            guide_task_str = ""
            self.is_special_guide = true
        end
    end

    -- e、 主线任务等级不足、有日常任务可以领取/做
    if not guide_task_id and self.is_non_existent_main_task and lv <= 260 and AutoTaskManager:GetInstance():IsCanAutoGuide(GuideItem4.AutoDailyTaskTip) then
        for i=1,len do
            local v = list[i]
            if v.task_type == enum.TASK_TYPE.TASK_TYPE_LOOP1 or v.task_type == enum.TASK_TYPE.TASK_TYPE_PREV1 or 
                v.task_type == enum.TASK_TYPE.TASK_TYPE_DAILY then
                guide_task_id = v.id
                guide_task_str = "Level up faster by finishing daily quests"
                self.is_special_guide = true
                break
            end
        end
    end

    if guide_task_id then
        self.last_guide_task_id = guide_task_id
        self.last_guide_task_str = guide_task_str
        self.last_guide_time = Time.time
        self:ResetGuideState()
    end

    return guide_task_id, guide_task_str
end

function TaskModel:ClearCurTaskGuide()
    self.last_guide_task_id = nil
    self.last_guide_task_str = nil
    self.last_guide_time = 0
    self.is_special_guide = false
end

function TaskModel:IsSpecialGuide(task_id)
    return task_id == self.last_guide_task_id and self.is_special_guide == true
end

function TaskModel:IsTaskConfigGuide(task_id)
    if not task_id then
        return false
    end
    local cf = Config.db_task[task_id]
    if cf and not string.isempty(cf.new) then
        return true
    end
    return false
end

function TaskModel:IsMainTaskGuide(task_id)
    if not task_id then
        return false
    end
    local task = self.task_list[task_id]
    if task and task.task_type == enum.TASK_TYPE.TASK_TYPE_MAIN then
        return self:IsTaskConfigGuide(task_id)
    end
    return false
end

function TaskModel:IsInGuideStopTask(task_id)
    if not task_id then
        return false
    end
    local cf = Config.db_task[task_id]
    -- if cf and cf.type == enum.TASK_TYPE.TASK_TYPE_MAIN then
    if cf then
        return cf.stop_task == 1
    end
    return false
end

function TaskModel:GetGoalValue(goals,value_key)
    if not goals then
        return nil
    end
    for k,goal in pairs(goals) do
        if goal and type(goal) == "table" and goal[1] ==value_key then
            return goal[2]
        end
    end
    return nil
end