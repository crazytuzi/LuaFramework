-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      任务的真实数据
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
TaskVo = TaskVo or BaseClass(EventDispatcher)

function TaskVo:__init(id, type)
    self.id = id
    self.type = type or TaskConst.type.quest
    if self.type == TaskConst.type.quest then
        self.config = Config.QuestData.data_get[id]
    elseif self.type == TaskConst.type.feat then
        self.config = Config.FeatData.data_get[id]
    elseif self.type == TaskConst.type.exp then
        self.config = Config.RoomFeatData.data_exp_info[id]
    end
    self.finish         = TaskConst.task_status.un_finish
    self.finish_sort    = 0
end

--[[ 根据任务完成状态获取任务的描述 ]]
function TaskVo:getTaskContent()
    return splitDataStr(self.config.desc)
end

--==============================--
--desc:获取任务的名
--time:2017-08-16 09:45:43
--@return
--==============================--
function TaskVo:getTaskName()
    if self.config then
        return self.config.name or ""
    else
        return ""
    end
end

--[[ 设置这个任务是否处于完成提交状态 ]]
function TaskVo:setCompletedStatus(status)
    self.finish = status
    self:setFinishSort()
    self:dispatchUpdate()
end

--[[
	更新任务数据
]]
function TaskVo:updateData(data)
    self.finish = data.finish
    self.progress = data.progress

    self:setFinishSort()
    self:dispatchUpdate()
end

function TaskVo:dispatchUpdate()
    self:Fire(TaskEvent.UpdateSingleQuest, self.id)
end

function TaskVo:setFinishSort()
    if self.finish == TaskConst.task_status.un_finish then
        self.finish_sort = 1
    elseif self.finish == TaskConst.task_status.finish then
        self.finish_sort = 0
    elseif self.finish == TaskConst.task_status.completed then
        self.finish_sort = 2
    else
        self.finish_sort = 3
    end
end

function TaskVo:__delete()
end
