-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-22
-- --------------------------------------------------------------------
TaskModel = TaskModel or BaseClass()

local table_insert = table.insert
local table_sort = table.sort

function TaskModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function TaskModel:config()
    self.task_list = {}             -- 当前所有任务数据，
    self.feat_list = {}             -- 当前成就所有数据

    self.task_status_list = {}              -- 任务icon的红点状态

    self.update_feat_status_list = {}       -- 待更新成就状态，延迟更新的
    self.finish_feat_list = {}

    --历练任务数据 --lwc
    self.dic_task_exp_data = {}
end

--[[
    @desc:需要检测的红点状态，分活跃度，任务或者成就3中
    author:{author}
    time:2018-05-22 15:50:49
    --@type: 
    return
]]
function TaskModel:checkQuestAndFeatStatus(type)
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    local red_status = false
    if type == TaskConst.update_type.activity then
        if self.activity_data ~= nil then
            for i,v in ipairs(Config.ActivityData.data_get) do
                if role_vo.activity >= v.activity and not self.activity_data[v.activity] then
                    red_status = true
                    break
                end
            end
        end
    elseif type == TaskConst.update_type.quest then
        if self.task_list ~= nil then
            for k,v in pairs(self.task_list) do
                if v.finish == TaskConst.task_status.finish then
                    red_status = true
                    break
                end
            end
        end
    elseif type == TaskConst.update_type.feat then
        if self.feat_list ~= nil then
            for k,v in pairs(self.feat_list) do
                if v.finish == TaskConst.task_status.finish then
                    red_status = true
                    break
                end
            end
        end
    elseif type == TaskConst.update_type.exp then
        local config = Config.RoomFeatData.data_const.experience_open_limit
        if config then
            if role_vo.lev >= config.val then
                if self.dic_task_exp_data then
                    for k,v in pairs(self.dic_task_exp_data) do
                        if v.finish == TaskConst.task_status.finish then
                            red_status = true
                            break
                        end
                    end
                end
            end
        end
    end
    if self.red_status_list == nil then
        self.red_status_list = {}
    end
    if self.red_status_list[type] == nil or (self.red_status_list[type] ~= nil and self.red_status_list[type] ~= red_status) then
        self.red_status_list[type] = red_status
        -- 抛出事件更新红点
        GlobalEvent:getInstance():Fire(TaskEvent.UpdateUIRedStatus, type, red_status)
    end

    -- 红点状态
    local num = FALSE
    if red_status == true then
        num = TRUE
    end
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.daily, {bid=type, num=num})
end

--[[
    @desc:用于日常面板上的红点接口判断
    author:{author}
    time:2018-05-28 14:41:18
    --@type: 
    return
]]
function TaskModel:getRedStatus(type)
    if self.red_status_list == nil then
        return false
    end
    return self.red_status_list[type]
end

--[[
    @desc:更新整个活跃度数据，只有在上线或者断线重连的时候更新
    author:{author}
    time:2018-05-22 16:14:11
    --@data: 
    return
]]
function TaskModel:updateActivityData(data_list)
    self.activity_data = {}
    for i,v in ipairs(data_list) do
        self.activity_data[v.activity] = true
    end
    self:checkQuestAndFeatStatus(TaskConst.update_type.activity)
    GlobalEvent:getInstance():Fire(TaskEvent.UpdateActivityInfo, self.activity_data)
end

--[[
    @desc:领取某个活跃度宝箱之后的更新，更新单个的
    author:{author}
    time:2018-05-22 16:14:40
    --@activity: 
    return
]]
function TaskModel:updateSingleActivityData(activity)
    if self.activity_data == nil then
        self.activity_data = {}
    end
    self.activity_data[activity] = true
    self:checkQuestAndFeatStatus(TaskConst.update_type.activity)
    GlobalEvent:getInstance():Fire(TaskEvent.UpdateActivityInfo, self.activity_data)
end

function TaskModel:getActivityData()
	return self.activity_data
end

--==============================--
--desc:增加或者更新任务
--time:2018-07-19 05:58:51
--@task_list:
--@is_update:
--@return 
--==============================--
function TaskModel:addTaskList(task_list, is_update, is_init)
    local taskVo, config = nil
    local is_new = false
    local finish_list = {}
    if is_init == true then self.task_list = {} end
    for i, v in ipairs(task_list) do
        config = Config.QuestData.data_get[v.id]
        if config ~= nil then
            if self.task_list[v.id] == nil then
                self.task_list[v.id] = TaskVo.New(v.id, TaskConst.type.quest)
                is_new = true
            else
                if v.finish == TRUE and is_update == true then
                    table_insert(finish_list, v.id)
                end
            end
            taskVo = self.task_list[v.id]
            taskVo:updateData(v)
        end
    end
    self:checkQuestAndFeatStatus(TaskConst.update_type.quest)
    GlobalEvent:getInstance():Fire(TaskEvent.UpdateTaskList,is_new,finish_list)
end

--[[
    @desc:设置一个任务为提交完成状态
    author:{author}
    time:2018-05-22 16:27:46
    --@id: 
    return
]]
function TaskModel:setTaskCompleted(id)
    local taskVo = self.task_list[id]
    if taskVo ~= nil then
        taskVo:setCompletedStatus(TaskConst.task_status.completed)
        self:checkQuestAndFeatStatus(TaskConst.update_type.quest)
        GlobalEvent:getInstance():Fire(TaskEvent.UpdateTaskList, false)
    end
end

--[[
    @desc:获取全部任务列表，这个根据 finish_sort 做了排序的
    author:{author}
    time:2018-05-22 19:23:23
    return
]]
function TaskModel:getTaskList()
    local task_list = {}
    for k,v in pairs(self.task_list) do
        table_insert(task_list, v)
    end
    if next(task_list) then
        local sort_func = SortTools.tableLowerSorter({"finish_sort", "id"})
        table_sort(task_list, sort_func)
    end
    return task_list
end

function TaskModel:getTaskById(id)
    return self.task_list[id]
end

function TaskModel:getFeatById(id)
    return self.feat_list[id]
end

--==============================--
--desc:增加或者更新任务
--time:2018-07-19 05:59:30
--@feat_list:
--@is_update:
--@return 
--==============================--
function TaskModel:addFeatList(feat_list, is_update, is_init)
    local taskVo, config = nil
    local is_new = false
    local finish_list = {}
    if is_init == true then self.feat_list = {} end
    for i, v in ipairs(feat_list) do
        config = Config.FeatData.data_get[v.id]
        if config ~= nil then
            if self.feat_list[v.id] == nil then
                self.feat_list[v.id] = TaskVo.New(v.id, TaskConst.type.feat)
                is_new = true
            else
                if v.finish == TRUE and is_update == true then
                    table_insert(finish_list, v.id)
                end
            end
            taskVo = self.feat_list[v.id]
            taskVo:updateData(v)
        end
    end
    self:checkQuestAndFeatStatus(TaskConst.update_type.feat)
    self:needUpdateFeat(is_new, finish_list)
end

function TaskModel:setFeatCompleted(id)
    local taskVo = self.feat_list[id]
    if taskVo ~= nil then
        taskVo:setCompletedStatus(TaskConst.task_status.completed)
        self:checkQuestAndFeatStatus(TaskConst.update_type.feat)
        self:needUpdateFeat(false)
    end
end

--[[
    @desc:是否需要抛出更新成就的事件，因为提交一个成就可能触发新增成就，所以如果都抛事件的话，会触发多次更新，做延迟抛出更新，避免次更新
    author:{author}
    time:2018-05-23 11:56:08
    --@status: 
    return
]]
function TaskModel:needUpdateFeat(status, finish_list)
    -- table_insert(self.update_feat_status_list, status)
    -- --  储存完成的成就
    -- if finish_list then
    --     for i,v in ipairs(finish_list) do
    --         table_insert(self.finish_feat_list, v)
    --     end
    -- end

    -- if self.wait_update == nil then
    --     self.wait_update = GlobalTimeTicket:getInstance():add(function() 
    --         local is_new = false 
    --         for i,v in ipairs(self.update_feat_status_list) do
    --             if v == true then
    --                 is_new = true
    --                 break
    --             end
    --         end    
            GlobalEvent:getInstance():Fire(TaskEvent.UpdateFeatList, finish_list)
    --         self.update_feat_status_list = {}
            -- self.finish_feat_list = {}
    --         GlobalTimeTicket:getInstance():remove(self.wait_update)
    --         self.wait_update = nil
    --     end, 0.2, 1)
    -- end
end

function TaskModel:getFeatList()
    local feat_list = {}
    for k,v in pairs(self.feat_list) do
        if v.finish ~= TaskConst.task_status.completed then
            table_insert(feat_list, v)
        end
    end
    if next(feat_list) then
        local sort_func = SortTools.tableLowerSorter({"finish_sort", "id"})
        table_sort(feat_list, sort_func)
    end
    return feat_list
end

---------------------------------历练数据开始-----------

--@scdata: 25810协议..和25811协议结构
--@is_check_notice 是否要检测任务完成通知
function TaskModel:updateTaskExpList(scdata, is_check_notice)
    if not scdata then return end
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo == nil then return end

    if is_check_notice == nil then
        self.dic_task_exp_data = {}
    end
    
    if scdata.feat_list then
        local finish_id_list = {}
        local hide_finish_id_list = {}
        for i,v in ipairs(scdata.feat_list) do
            if self.dic_task_exp_data[v.id] then
                for k,val in pairs(v) do
                    self.dic_task_exp_data[v.id][k] = val
                end
            else
                local config = Config.RoomFeatData.data_exp_info[v.id]
                if config then
                    self.dic_task_exp_data[v.id] = TaskVo.New(v.id, TaskConst.type.exp)
                    for k,val in pairs(v) do
                        self.dic_task_exp_data[v.id][k] = val
                    end
                end
            end 

            if is_check_notice and v.finish == TaskConst.task_status.finish and self.dic_task_exp_data[v.id].config then
                local lev = self.dic_task_exp_data[v.id].config.lev or 0
                if role_vo.lev >= lev then
                    if self.dic_task_exp_data[v.id].config.hide == 1 then
                        --隐藏成就
                        table_insert(hide_finish_id_list, v.id)
                    else
                        table_insert(finish_id_list, v.id)
                    end
                end 
            end
        end

        if is_check_notice then
            local config_limit = Config.RoomFeatData.data_const.experience_open_limit
            if config_limit then
                if role_vo.lev >= config_limit.val then
                    --任务完成了需要提示一下
                    if next(finish_id_list) ~= nil then
                        GlobalEvent:getInstance():Fire(TaskEvent.TASK_EXP_FINISH_TIPS_EVENT, finish_id_list)
                    end

                    if next(hide_finish_id_list) ~= nil then
                        --这里打开隐藏成就ui
                        for i,id in ipairs(hide_finish_id_list) do
                            BattleResultMgr:getInstance():addShowData(BattleConst.Closed_Result_Type.TaskExpType, {id = id})
                        end
                    end
                end
            else
                if next(finish_id_list) ~= nil then
                    GlobalEvent:getInstance():Fire(TaskEvent.TASK_EXP_FINISH_TIPS_EVENT, finish_id_list)
                end

                if next(hide_finish_id_list) ~= nil then
                    --这里打开隐藏成就ui
                    for i,id in ipairs(hide_finish_id_list) do
                        BattleResultMgr:getInstance():addShowData(BattleConst.Closed_Result_Type.TaskExpType, {id = id})
                    end
                end
            end
        end
    end
    
    if scdata.finish_list then
        for i,v in ipairs(scdata.finish_list) do
            local config = Config.RoomFeatData.data_exp_info[v.id]
            if config then
                self.dic_task_exp_data[v.id] = TaskVo.New(v.id, TaskConst.type.exp)
                self.dic_task_exp_data[v.id].finish = TaskConst.task_status.completed
                for k,val in pairs(v) do
                    self.dic_task_exp_data[v.id][k] = val
                end
            end
        end
    end
    self:checkQuestAndFeatStatus(TaskConst.update_type.exp)
end

function TaskModel:getSaveAchieveData()
    if self.achieve_data then
        return self.achieve_data
    end
    return nil
end


--根据id 更新历练已完成时间 并标志为已完成状态
function TaskModel:updateTaskExpDataByID(id, time)
    if self.dic_task_exp_data[id] then
        self.dic_task_exp_data[id].finish_time = time
        self.dic_task_exp_data[id].finish = TaskConst.task_status.completed
        self:checkQuestAndFeatStatus(TaskConst.update_type.exp)
    end
end

function TaskModel:getTaskExpList()
    return self.dic_task_exp_data or {}
end

function TaskModel:getTaskExpListById(id)
    if self.dic_task_exp_data then
        return self.dic_task_exp_data[id]
    end
end




---------------------------------历练数据开始-----------

function TaskModel:__delete()
end
