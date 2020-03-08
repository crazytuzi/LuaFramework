local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local FinishMajorTask = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = FinishMajorTask.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local TaskInterface = require("Main.task.TaskInterface")
  local taskInterface = TaskInterface.Instance()
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
  local taskInfos = taskInterface:GetTaskInfos()
  for taskId, graphIdValue in pairs(taskInfos) do
    for graphId, info in pairs(graphIdValue) do
      local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
      if graphCfg.taskType == TaskConsts.TASK_TYPE_MAIN then
        if info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH then
          Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskId, graphId})
          return true
        elseif info.state == TaskConsts.TASK_STATE_CAN_ACCEPT then
          Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskId, graphId})
          return true
        elseif info.state == TaskConsts.TASK_STATE_VISIABLE then
          if info.unConDataIDs ~= nil then
            local taskCfg = TaskInterface.GetTaskCfg(taskId)
            for idx, uncondID in pairs(info.unConDataIDs) do
              for i, v in pairs(taskCfg.acceptConIds) do
                if uncondID == v.id and v.classType == TaskConClassType.CON_LEVEL then
                  local cond = TaskInterface.GetTaskConditionLevel(v.id)
                  Toast(string.format(textRes.Task[161], cond.minLevel))
                  return false
                end
              end
            end
          end
          break
        end
      end
    end
  end
  return false
end
return FinishMajorTask.Commit()
