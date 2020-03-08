local MODULE_NAME = (...)
local Lplus = require("Lplus")
local InteractiveMainViewModel = Lplus.Class(MODULE_NAME)
local InteractiveTaskModule = Lplus.ForwardDeclare("InteractiveTaskModule")
local InteractiveTaskUtils = require("Main.InteractiveTask.InteractiveTaskUtils")
local def = InteractiveMainViewModel.define
local instance
def.static("=>", InteractiveMainViewModel).Instance = function()
  if instance == nil then
    instance = InteractiveMainViewModel()
  end
  return instance
end
def.method("=>", "boolean").IsInvalid = function(self)
  TODO("debug:IsInvalid=false")
  do return false end
  return not InteractiveTaskModule.Instance():IsInTaskMap()
end
def.method("=>", "number").GetTypeId = function(self)
  return InteractiveTaskModule.Instance():GetWorkedTypeId()
end
def.method("=>", "string").GetTypeName = function(self)
  local typeId = self:GetTypeId()
  local cfg = InteractiveTaskUtils.GetInteractiveTaskTypeCfg(typeId)
  if cfg == nil then
    return "[missing]"
  else
    return cfg.typeName
  end
end
def.method("=>", "number").GetTypeEndTime = function(self)
  local typeId = self:GetTypeId()
  local graphState = InteractiveTaskModule.Instance():GetGraphsState(typeId)
  if graphState == nil then
    return 0
  end
  return graphState.endTime:ToNumber()
end
def.method("=>", "table").GetAllTasks = function(self)
  local typeId = self:GetTypeId()
  local cfg = InteractiveTaskUtils.GetInteractiveTaskCfg(typeId)
  if cfg == nil then
    return {}
  end
  local graphState = InteractiveTaskModule.Instance():GetGraphsState(typeId)
  local finishedGraphsMap = {}
  for i, v in ipairs(graphState and graphState.finishedGraphs or {}) do
    finishedGraphsMap[v] = v
  end
  local tasks = {}
  for i, v in ipairs(cfg.graphs) do
    local task = {}
    task.name = v.name
    task.graphId = v.graphId
    task.typeId = typeId
    task.iconId = v.iconId
    if graphState then
      if task.graphId == graphState.currentGraph then
        task.state = "accepted"
      elseif finishedGraphsMap[task.graphId] then
        task.state = "finished"
      else
        task.state = "none"
      end
    end
    tasks[#tasks + 1] = task
  end
  return tasks
end
return InteractiveMainViewModel.Commit()
