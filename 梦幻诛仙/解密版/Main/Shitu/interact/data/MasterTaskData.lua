local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ShituData = require("Main.Shitu.ShituData")
local ShiTuTaskInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuTaskInfo")
local ShiTuTask = require("netio.protocol.mzm.gsp.shitu.ShiTuTask")
local MasterTaskData = Lplus.Class(CUR_CLASS_NAME)
local def = MasterTaskData.define
def.field("userdata")._roleId = nil
def.field("number")._assignState = -1
def.field("number")._refreshCount = 0
def.field("number")._totalFinishCount = 0
def.field("table")._taskInfos = nil
def.final("table", "=>", MasterTaskData).New = function(p)
  if nil == p then
    return nil
  end
  local taskData = MasterTaskData()
  taskData._roleId = p.role_id
  taskData._assignState = p.publish_state
  taskData._refreshCount = p.refresh_times
  taskData._totalFinishCount = p.shitu_task_count
  taskData._taskInfos = {}
  if p.task_infos then
    for graphId, taskInfo in pairs(p.task_infos) do
      local task = {}
      task.graphId = graphId
      task.taskId = taskInfo.task_id
      task.taskState = taskInfo.task_state
      table.insert(taskData._taskInfos, task)
    end
  end
  return taskData
end
def.method().Release = function(self)
  self._roleId = nil
  self._assignState = -1
  self._refreshCount = 0
  self._totalFinishCount = 0
  self._taskInfos = nil
end
def.method("=>", "table").GetTaskInfos = function(self)
  return self._taskInfos
end
def.method("number", "=>", "table").GetTaskInfoByIdx = function(self, idx)
  local taskInfo
  if self._taskInfos and #self._taskInfos > 0 then
    taskInfo = self._taskInfos[idx]
  end
  return taskInfo
end
def.method("number", "number", "=>", "table").GetTaskInfo = function(self, graphId, taskId)
  local result
  if self._taskInfos and #self._taskInfos > 0 then
    for _, taskInfo in pairs(self._taskInfos) do
      if taskInfo.taskId == taskId and taskInfo.graphId == graphId then
        result = taskInfo
        break
      end
    end
  end
  return result
end
def.method("number", "number", "number").UpdateTaskState = function(self, graphId, taskId, taskState)
  local taskInfo = self:GetTaskInfo(graphId, taskId)
  if taskInfo then
    taskInfo.taskState = taskState
    warn(string.format("[MasterTaskData:UpdateTaskState] update graphId[%d] taskId[%d], set taskState=[%d].", graphId, taskId, taskState))
  else
    warn(string.format("[ERROR][MasterTaskData:UpdateTaskState] update failed! taskInfo nil for graphId[%d], taskId[%d].", graphId, taskId))
  end
end
def.method("=>", "userdata").GetRoleId = function(self)
  return self._roleId
end
def.method("=>", "number").GetAssignState = function(self)
  return self._assignState
end
def.method("=>", "number").GetRefreshCount = function(self)
  return self._refreshCount
end
def.method("=>", "number").GetTotalFinishCount = function(self)
  return self._totalFinishCount
end
def.method("=>", "boolean").NeedReddot = function(self)
  return self:HaveUnAssignedTask() or self:HavePrenticeTaskAward()
end
def.method("=>", "boolean").HaveUnAssignedTask = function(self)
  if ShituData.Instance():IsMyApprentice(self._roleId) and self._assignState == ShiTuTaskInfo.NO_PUBLISHED then
    return true
  else
    return false
  end
end
def.method("=>", "boolean").HavePrenticeTaskAward = function(self)
  local result = false
  if ShituData.Instance():IsMyApprentice(self._roleId) and self._taskInfos and #self._taskInfos > 0 then
    for _, taskInfo in ipairs(self._taskInfos) do
      if taskInfo.taskState == ShiTuTask.FINISHED then
        result = true
        break
      end
    end
  end
  return result
end
def.method("=>", "boolean").HaveUnFinishedTask = function(self)
  local result = false
  local taskState = self:GetAssignState()
  if taskState == ShiTuTaskInfo.YES_PUBLISHED or taskState == ShiTuTaskInfo.APPRENTICE_RECEIVED then
    local taskInfos = self:GetTaskInfos()
    if taskInfos and #taskInfos > 0 then
      for _, taskInfo in ipairs(taskInfos) do
        if taskInfo.taskState == ShiTuTask.UN_ACCEPTED or taskInfo.taskState == ShiTuTask.ALREADY_ACCEPTED then
          result = true
          break
        end
      end
    end
  end
  return result
end
return MasterTaskData.Commit()
