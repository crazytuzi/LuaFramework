local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local InteractiveTaskModule = Lplus.Extend(ModuleBase, "InteractiveTaskModule")
local InteractiveTaskUtils = require("Main.InteractiveTask.InteractiveTaskUtils")
local def = InteractiveTaskModule.define
def.const("number").NO_GRAPH = 0
def.const("number").RESPONSE_ACCEPT = 1
def.const("number").RESPONSE_REFUSE = 0
def.field("table").m_typeid2graphs = nil
def.field("table").m_taskMapIds = nil
local instance
def.static("=>", InteractiveTaskModule).Instance = function()
  if instance == nil then
    instance = InteractiveTaskModule()
    instance.m_moduleId = ModuleId.INTERACTIVE_TASK
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interactivetask.SSynInteractiveTaskRes", InteractiveTaskModule.OnSSynInteractiveTaskRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interactivetask.SSynInteractiveTaskInfoRes", InteractiveTaskModule.OnSSynInteractiveTaskInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interactivetask.SReceiveInviteStartTaskRes", InteractiveTaskModule.OnSReceiveInviteStartTaskRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interactivetask.SReceiveStartTaskRes", InteractiveTaskModule.OnSReceiveStartTaskRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interactivetask.SFinishTaskRes", InteractiveTaskModule.OnSFinishTaskRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.interactivetask.SErrorInfo", InteractiveTaskModule.OnSErrorInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, InteractiveTaskModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, InteractiveTaskModule.OnChangeMap)
end
def.method("=>", "number").GetWorkedTypeId = function(self)
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  if not self:IsTaskMap(mapId) then
    return 0
  end
  return self.m_taskMapIds[mapId]
end
def.method("number", "=>", "number").GetMapTaskTypeId = function(self, mapId)
  if self.m_taskMapIds == nil then
    self.m_taskMapIds = InteractiveTaskUtils.GetAllInteractiveTaskMaps()
  end
  return self.m_taskMapIds[mapId] or 0
end
def.method("number", "=>", "table").GetGraphsState = function(self, typeId)
  if self.m_typeid2graphs == nil then
    return nil
  end
  return self.m_typeid2graphs[typeId]
end
def.method("number", "=>", "number").GetAcceptedTaskGraphId = function(self, typeId)
  if self.m_typeid2graphs == nil then
    return InteractiveTaskModule.NO_GRAPH
  end
  return self.m_typeid2graphs[typeId].currentGraph
end
def.method("number", "number", "=>", "boolean").IsTaskAcceptable = function(self, typeId, graphId)
  if self.m_typeid2graphs == nil then
    return false
  end
  local graphState = self.m_typeid2graphs[typeId]
  if graphState.currentGraph ~= InteractiveTaskModule.NO_GRAPH then
    return false
  end
  for i, v in ipairs(graphState.finishedGraphs) do
    if v == graphId then
      return false
    end
  end
  local cfg = InteractiveTaskUtils.GetInteractiveTaskCfg(typeId)
  if cfg.isSeq then
    local nextIndex = #graphState.finishedGraphs + 1
    if cfg.graphs[nextIndex] and cfg.graphs[nextIndex].graphId == graphId then
      return true
    end
  else
    for i, v in ipairs(cfg.graphs) do
      if v.graphId == graphId then
        return true
      end
    end
  end
  return false
end
def.method("number", "=>", "boolean").IsTaskMap = function(self, mapId)
  local typeId = self:GetMapTaskTypeId(mapId)
  return typeId ~= 0 and true or false
end
def.method("=>", "boolean").IsInTaskMap = function(self)
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  return self:IsTaskMap(mapId)
end
def.method().AbortWorkedTask = function(self)
  local typeId = self:GetWorkedTypeId()
  if typeId == 0 then
    return
  end
  self:EndInteractiveTask(typeId)
end
def.method().ShowCommanderUI = function(self)
  require("Main.InteractiveTask.ui.InteractiveMainPanel").Instance():ShowPanel()
end
def.method("number", "=>", "boolean").IsAllTasksFinished = function(self, typeId)
  local cfg = InteractiveTaskUtils.GetInteractiveTaskCfg(typeId)
  if cfg == nil then
    return false
  end
  local graphState = self:GetGraphsState(typeId)
  if graphState == nil then
    return false
  end
  local finishedMap = {}
  for i, v in ipairs(graphState.finishedGraphs) do
    finishedMap[v] = v
  end
  for i, graph in ipairs(cfg.graphs) do
    if finishedMap[graph.graphId] == nil then
      return false
    end
  end
  return true
end
def.method("number").OnEnterTaskMap = function(self, mapId)
  local typeId = self:GetMapTaskTypeId(mapId)
  Event.DispatchEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.ENTER_TASK_MAP, {typeId})
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, function()
    self:AbortWorkedTask()
  end, nil, true, CommonActivityPanel.ActivityType.INTERACTIVE_TASK)
end
def.method("number").OnLeaveTaskMap = function(self, mapId)
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.INTERACTIVE_TASK)
  local typeId = self:GetMapTaskTypeId(mapId)
  Event.DispatchEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.LEAVE_TASK_MAP, {typeId})
end
def.method("number").OnAllTasksFinished = function(self, typeId)
  local itaskTypeCfg = InteractiveTaskUtils.GetInteractiveTaskTypeCfg(typeId)
  if itaskTypeCfg == nil then
    return
  end
  local effectId = itaskTypeCfg.effectId
  if effectId ~= 0 then
    local effectCfg = GetEffectRes(effectId)
    if nil == effectCfg then
      warn("InteractiveTaskModule::OnAllTasksFinished: effet cfg is nil ~~~~~~~~~~~~ id = " .. effectId)
      return
    end
    local GUIFxMan = require("Fx.GUIFxMan")
    local lifetime = itaskTypeCfg.delaySeonds + 2
    local fx = GUIFxMan.Instance():Play(effectCfg.path, "OnAllTasksFinished_" .. typeId, 0, 0, lifetime, false)
  end
  local function finish(...)
    self:EndInteractiveTask(typeId)
    Event.DispatchEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.ALL_TASKS_FINISHED, {typeId})
  end
  if 0 < itaskTypeCfg.delaySeonds then
    GameUtil.AddGlobalTimer(itaskTypeCfg.delaySeonds, true, function(...)
      if _G.IsEnteredWorld() then
        finish()
      end
    end)
  else
    finish()
  end
end
def.method("number").BeginInteractiveTask = function(self, typeId)
  local itaskTypeCfg = InteractiveTaskUtils.GetInteractiveTaskTypeCfg(typeId)
  local typeName = itaskTypeCfg and itaskTypeCfg.typeName or ""
  local costCurrencyType = itaskTypeCfg and itaskTypeCfg.costCurrencyType or 0
  local costCurrencyNum = itaskTypeCfg and itaskTypeCfg.costCurrencyNum or 0
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  if costCurrencyType == MoneyType.NULL or costCurrencyNum <= 0 then
    self:CJoinInteractiveTaskReq(typeId)
    return
  end
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local currencyData = CurrencyFactory.Create(costCurrencyType)
  local currencyName = currencyData:GetName()
  local desc = string.format(textRes.InteractiveTask[11], typeName, costCurrencyNum, currencyName)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(typeName, desc, function(s)
    if s == 1 then
      if currencyData:GetHaveNum():ge(costCurrencyNum) then
        self:CJoinInteractiveTaskReq(typeId)
      else
        Toast(string.format(textRes.InteractiveTask[12], currencyName))
      end
    end
  end, nil)
end
def.method("number").CJoinInteractiveTaskReq = function(self, typeId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.interactivetask.CJoinInteractiveTaskReq").new(typeId))
end
def.method("number").EndInteractiveTask = function(self, typeId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.interactivetask.CQuitInteractiveTaskReq").new(typeId))
end
def.method("number", "number").InviteStartTask = function(self, typeId, graphId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.interactivetask.CSendInviteStartTaskReq").new(typeId, graphId))
end
def.method("number", "number", "number").ReplyStartTaskInvite = function(self, typeId, graphId, response)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.interactivetask.CSendStartTaskReq").new(response, typeId, graphId))
end
def.method("number", "table").InitGraphState = function(self, typeId, option)
  self.m_typeid2graphs = self.m_typeid2graphs or {}
  local graphState = {}
  graphState.finishedGraphs = {}
  graphState.currentGraph = InteractiveTaskModule.NO_GRAPH
  graphState.isCommander = option.isCommander
  self.m_typeid2graphs[typeId] = graphState
end
def.static("table").OnSSynInteractiveTaskRes = function(p)
  instance.m_typeid2graphs = p.typeid2graphs
end
def.static("table").OnSSynInteractiveTaskInfoRes = function(p)
  instance.m_typeid2graphs = instance.m_typeid2graphs or {}
  instance.m_typeid2graphs[p.typeid] = p.taskInfo
  Event.DispatchEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.TASK_STAUS_CHANGED, {
    p.typeid,
    0
  })
end
def.static("table").OnSReceiveInviteStartTaskRes = function(p)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local graphCfg = InteractiveTaskUtils.GetInteractiveGraphCfg(p.typeid, p.graphid)
  local itaskTypeCfg = InteractiveTaskUtils.GetInteractiveTaskTypeCfg(p.typeid)
  require("Main.npc.ui.NPCDlg").Instance():HideDlg()
  local content = string.format(textRes.InteractiveTask[1], itaskTypeCfg.commanderAppellation, graphCfg.name)
  CommonConfirmDlg.ShowConfirm("", content, function(s)
    local response = InteractiveTaskModule.RESPONSE_REFUSE
    if s == 1 then
      response = InteractiveTaskModule.RESPONSE_ACCEPT
    end
    instance:ReplyStartTaskInvite(p.typeid, p.graphid, response)
  end, {
    unique = InteractiveTaskModule.OnSReceiveInviteStartTaskRes
  })
end
def.static("table").OnSReceiveStartTaskRes = function(p)
  local graphState = instance:GetGraphsState(p.typeid)
  if graphState == nil then
    return
  end
  if p.result == InteractiveTaskModule.RESPONSE_ACCEPT then
    graphState.currentGraph = p.graphid
    Event.DispatchEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.TASK_STAUS_CHANGED, {
      p.typeid,
      p.graphid
    })
  else
    local itaskTypeCfg = InteractiveTaskUtils.GetInteractiveTaskTypeCfg(p.typeid)
    local content = string.format(textRes.InteractiveTask[3], itaskTypeCfg.executorAppellation)
    Toast(content)
  end
end
def.static("table").OnSFinishTaskRes = function(p)
  if instance.m_typeid2graphs == nil then
    warn(string.format("OnSFinishTaskRes: instance.m_typeid2graphs is nil!"))
    return
  end
  local graphState = instance.m_typeid2graphs[p.typeid]
  if graphState == nil then
    warn(string.format("OnSFinishTaskRes: instance.m_typeid2graphs[%d] is nil!", p.typeid))
    return
  end
  table.insert(graphState.finishedGraphs, p.graphid)
  graphState.currentGraph = InteractiveTaskModule.NO_GRAPH
  Event.DispatchEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.TASK_STAUS_CHANGED, {
    p.typeid,
    p.graphid
  })
  Event.DispatchEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.TASK_FINISHED, {
    p.typeid,
    p.graphid
  })
  if instance:IsAllTasksFinished(p.typeid) then
    instance:OnAllTasksFinished(p.typeid)
  end
end
def.static("table").OnSErrorInfo = function(p)
  local text = textRes.InteractiveTask.SErrorInfo[p.errorCode]
  if text then
    if p.errorCode == p.class.ROLE_OFF_LINE then
      local itaskTypeCfg = InteractiveTaskUtils.GetInteractiveTaskTypeCfg(p.typeid)
      text = string.format(text, itaskTypeCfg.executorAppellation, itaskTypeCfg.typeName)
    end
  else
    text = string.format("InteractiveTaskModule::Error(%d)", p.errorCode)
  end
  Toast(text)
end
def.static("table", "table").OnLeaveWorld = function()
  instance.m_typeid2graphs = nil
end
def.static("table", "table").OnChangeMap = function(p1, p2)
  local mapId = p1[1]
  local oldMapId = p1[2]
  if instance:IsTaskMap(oldMapId) then
    instance:OnLeaveTaskMap(oldMapId)
  end
  if instance:IsTaskMap(mapId) then
    instance:OnEnterTaskMap(mapId)
  end
end
return InteractiveTaskModule.Commit()
