local Lplus = require("Lplus")
local LoadingMgr = Lplus.Class("LoadingMgr")
local LoadingPanel = require("GUI.LoadingPanel")
local def = LoadingMgr.define
def.const("table").LoadingType = {
  EnterWorld = 1,
  ChangeMap = 2,
  Other = 3,
  CrossServer = 4,
  InWorld = 5,
  SwitchOccupation = 6
}
local enableLog = false
local function log(...)
  if enableLog then
    warn(...)
  end
end
def.field("table").taskList = nil
def.field("table").taskProgressList = nil
def.field("number").taskAmount = 0
def.field("number").progress = 0
def.field("number").totalWeight = 1
def.field("function").callback = nil
def.field("table").tag = nil
def.field("number").loadingType = 0
def.field("table").loadingPanel = nil
def.field("table").resCache = nil
local instance
def.static("=>", LoadingMgr).Instance = function()
  if instance == nil then
    instance = LoadingMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RE_LOGIN, LoadingMgr.OnAbort)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.BACK_TO_LOGIN, LoadingMgr.OnAbort)
  self.resCache = {}
end
def.method("=>", "boolean").IsLoading = function(self)
  return self.loadingType ~= 0
end
def.method("number", "table", "function", "table").StartLoading = function(self, loadingType, taskList, callback, tag)
  local loadingPanel = LoadingPanel.Instance()
  local tip = self:GetRandomTip()
  loadingPanel:SetTip(tip)
  self:StartLoadingEx(loadingType, taskList, callback, tag, loadingPanel)
end
def.method("number", "table", "function", "table", "table").StartLoadingEx = function(self, loadingType, taskList, callback, tag, loadingPanel)
  self.loadingType = loadingType
  self.callback = callback
  self.tag = tag
  self:SetTaskList(taskList)
  if self.loadingPanel then
    self.loadingPanel:DestroyPanel()
  end
  self.loadingPanel = loadingPanel
  if self.loadingPanel then
    self.loadingPanel:ShowPanel()
  end
end
def.method("function").SetLoadingUIReadyCallback = function(self, func)
  if self.loadingPanel then
    self.loadingPanel.afterCreateCallback = func
  end
end
def.method("=>", "string").GetRandomTip = function(self)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local level = heroProp and heroProp.level or 0
  return require("Main.Common.TipsHelper").Instance():GetRandomTip(level)
end
def.method("table").SetTaskList = function(self, taskList)
  self.taskList = {}
  self.taskAmount = table.nums(taskList)
  self.taskProgressList = {}
  local weightCount = 0
  for type, weight in pairs(taskList) do
    weightCount = weightCount + weight
    self.taskProgressList[type] = 0
    if weight == 0 then
      self.taskProgressList[type] = 1
    end
  end
  if weightCount <= 0 then
    error(string.format("Total weight is (%f), must greater than zero.", weightCount), 3)
  end
  for type, weight in pairs(taskList) do
    self.taskList[type] = weight / weightCount
  end
  self.totalWeight = weightCount
end
def.method("number", "table").ExecuteAsyncLoadTask = function(self, type, resPathList)
  if self.taskList[type] == nil then
    warn(string.format("LoadingPanel don't have type(%d) task", type))
    return
  end
  local resTotalCount = #resPathList
  local resCount = 0
  for i, resPath in ipairs(resPathList) do
    GameUtil.AsyncLoad(resPath, function(obj)
      if obj == nil then
        warn(string.format("Resources preload failed: %s", resPath))
      end
      self.resCache[resPath] = obj
      resCount = resCount + 1
      local rate = resCount / resTotalCount
      self:UpdateTaskProgress(type, rate)
    end)
  end
end
def.method("number", "number").UpdateTaskProgress = function(self, type, rate)
  if self.taskProgressList == nil then
    return
  end
  if self.taskProgressList[type] == nil then
    warn(string.format("In loading, don't have type = %d task", type))
    return
  end
  log(string.format("UpdateTaskProgress type=%d, rate=%f", type, rate))
  self.taskProgressList[type] = rate
  local progress = self:GetTotalProgress()
  if self.loadingPanel then
    self.loadingPanel:SetProgress(progress)
  end
  local finishedTaskNum = self:GetFinishedTaskNum()
  if finishedTaskNum >= self.taskAmount then
    local durationTime = self:GetFinishDelayTime()
    GameUtil.AddGlobalTimer(durationTime, true, function()
      self:FinishLoading()
    end)
  end
end
def.method("=>", "number").GetFinishDelayTime = function(self)
  return 1
end
def.method("=>", "number").GetFinishedTaskNum = function(self)
  if self.taskProgressList == nil then
    return 0
  end
  local num = 0
  for i, v in ipairs(self.taskProgressList) do
    if v >= 1 then
      num = num + 1
    end
  end
  return num
end
def.method("=>", "number").GetTotalProgress = function(self)
  local progress = 0
  for k, v in pairs(self.taskProgressList) do
    progress = progress + v * self.taskList[k]
  end
  return progress
end
def.method("=>", "table").GetAllTaskProgresses = function(self)
  return self.taskProgressList
end
def.method("number", "=>", "table").GetTaskProgress = function(self, type)
  if self.taskProgressList == nil then
    return nil
  end
  return self.taskProgressList[type]
end
local start_deadlock_detect = false
def.method().FinishLoading = function(self)
  self:Clear()
  local timerid
  local CG = require("CG.CG")
  local cginst = CG.Instance()
  if cginst.m_waitloading then
    do
      local timeend = Time.time + 5
      timerid = GameUtil.AddGlobalTimer(0.1, false, function()
        if Time.time > timeend or not cginst.m_waitloading then
          GameUtil.RemoveGlobalTimer(timerid)
          cginst.m_waitloading = false
          self:DestroyLoadingPanel()
        end
      end)
    end
  else
    self:DestroyLoadingPanel()
  end
  self:DoCallback(true)
  if not start_deadlock_detect then
    start_deadlock_detect = true
    if not Application.isEditor then
      GameUtil.StartDeadLockDetect(30000, 2000, false)
    end
  end
end
def.method("boolean").DoCallback = function(self, isSuccess)
  if self.callback == nil then
    return
  end
  self.callback(isSuccess, self.tag)
  self.callback = nil
  self.tag = nil
end
def.method("string").ReleaseCache = function(self, resPath)
  self.resCache[resPath] = nil
end
def.method().Clear = function(self)
  self.taskList = nil
  self.taskProgressList = nil
  self.taskAmount = 0
  self.progress = 0
  self.totalWeight = 1
  self.loadingType = 0
end
def.method().DestroyLoadingPanel = function(self)
  if self.loadingPanel then
    self.loadingPanel:DestroyPanel()
    self.loadingPanel = nil
  end
end
def.static("table", "table").OnAbort = function()
  instance:DoCallback(false)
  instance:Clear()
  instance:DestroyLoadingPanel()
end
return LoadingMgr.Commit()
