local Lplus = require("Lplus")
local SubtaskBase = require("Main.Soaring.proxy.SubtaskBase")
local TaskWayOfCoatard = Lplus.Extend(SubtaskBase, "TaskWayOfCoatard")
local SoaringTaskActivityData = require("Main.Soaring.data.SoaringTaskActivityData")
local def = TaskWayOfCoatard.define
local instance
def.field("table")._cfgData = nil
def.const("number").ACTIVITY_ID = constant.CFeiShengConsts.XIU_ZHEN_ZHI_TU_ACTIVITY_CFG_ID
def.static("=>", TaskWayOfCoatard).Instance = function()
  if instance == nil then
    instance = TaskWayOfCoatard()
  end
  return instance
end
def.override().OnTodoTask = function(self)
  self:_loadData()
  local npc_id = self._cfgData:GetNPCId()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npc_id})
  self:Release()
end
def.override("number", "number", "=>", "boolean").OnDoTask = function(self, npcid, serviceId)
  self:_loadData()
  local srvcId = self._cfgData:GetNPCServiceId()
  local graphId = self._cfgData:taskGraphId()
  self:Release()
  if serviceId == srvcId then
    local SoaringModule = require("Main.Soaring.SoaringModule")
    if not SoaringModule.CanJoinActivity() then
      return true
    end
    local bIsCompleted = require("Main.Soaring.SoaringModule").GetActivityCompletedByActId(TaskWayOfCoatard.ACTIVITY_ID)
    if bIsCompleted then
      Toast(textRes.Soaring.WayOfCoatard[1])
    else
      local TaskInterface = require("Main.task.TaskInterface")
      local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
      local taskId = TaskInterface.Instance():GetTaskIdByGraphId(graphId)
      local taskState = TaskInterface.Instance():GetTaskState(taskId, graphId)
      if taskState ~= -1 then
        Toast(textRes.Soaring.WayOfCoatard[2])
      else
        TaskWayOfCoatard.SendCAttendTaskActivityReq()
      end
    end
    return true
  end
  return false
end
local fx
def.method().DisplayMapEffect = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskWayOfCoatard.ACTIVITY_ID) then
    return
  end
  self:_loadData()
  local effectInfo = self._cfgData:GetEffectInfo()
  self:Release()
  fx = SoaringModule.PlayMapEffect(effectInfo.effectId, effectInfo.x, effectInfo.y)
end
def.method().UpdateNPCState = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskWayOfCoatard.ACTIVITY_ID) then
    return
  end
  self:_loadData()
  local npc_id = self._cfgData:GetNPCId()
  local talkContent = self._cfgData:GetTalkContent()
  self:Release()
  local NPCState = require("consts.mzm.gsp.npc.confbean.NPCState")
  if SoaringModule.IsSoaringActComplete() then
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_STATE, {
      npcid = npc_id,
      state = NPCState.NORMAL
    })
  else
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_STATE, {
      npcid = npc_id,
      state = NPCState.MAGIC
    })
  end
  self:Talk(npc_id, talkContent)
end
local G_bActInfoChange = false
def.static("boolean").SetActInfoChange = function(bChanged)
  G_bActInfoChange = bChanged
end
def.method("number", "string").Talk = function(self, npcid, talkContent)
  if not G_bActInfoChange then
    return
  end
  local triedTime = 0
  require("Main.Soaring.SoaringModule").ShowTalk(npcid, talkContent, triedTime, TaskWayOfCoatard)
end
local ECFxMan = require("Fx.ECFxMan")
def.method().RemoveMapEffect = function(self)
  if fx == nil or fx == 0 then
    return
  end
  _G.MapEffect_ReleaseRes(fx)
  fx = 0
end
local NPCInterface = require("Main.npc.NPCInterface")
def.method().DisplayActFinishUI = function(self)
  self:_loadData()
  local npc_id = self._cfgData:GetNPCId()
  local npcCfg = NPCInterface.GetNPCCfg(npc_id)
  local desc = textRes.Soaring.WayOfCoatard[3]:format(npcCfg.npcName)
  local duration = require("Main.Soaring.SoaringModule").ACTFINISH_UI_DURATION
  require("Main.Marriage.ui.MarryNotice").ShowMarryNotice(desc, duration)
  self:Release()
end
def.method()._loadData = function(self)
  if self._cfgData == nil or self._cfgData:IsNil() then
    self._cfgData = SoaringTaskActivityData.Instance()
    self._cfgData:InitData(TaskWayOfCoatard.ACTIVITY_ID)
  end
end
def.override().Release = function(self)
  if self._cfgData ~= nil then
    self._cfgData:Release()
    self._cfgData = nil
  end
end
def.static("number", "=>", "table").FastGetCfgData = function(actId)
  local cfgData = SoaringTaskActivityData.Instance()
  cfgData:InitData(actId)
  local retData = {}
  retData.npc_id = cfgData:GetNPCId()
  cfgData:Release()
  return retData
end
def.static().RegisterTaskClass = function()
  local SoaringModule = require("Main.Soaring.SoaringModule")
  SoaringModule.RegisterTaskClass(TaskWayOfCoatard.ACTIVITY_ID, TaskWayOfCoatard)
end
def.static().SendCAttendTaskActivityReq = function()
  warn(">>>>SendCAttendTaskActivityReq<<<<")
  local p = require("netio.protocol.mzm.gsp.feisheng.CAttendTaskActivityReq").new(TaskWayOfCoatard.ACTIVITY_ID)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSAttendTaskActivityFail = function(p)
  warn(">>>>SAttendTaskActivityFail <<<<")
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>CHECK_NPC_SERVICE_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == 2 then
    warn(">>>>ACTIVE_TASK_GRAPH_FAIL<<<<")
  elseif p.res == 3 then
    warn(">>>>AWARD_FAIL<<<<")
  end
end
def.static("table").OnSAttendTaskActivitySuccess = function(p)
  warn(">>>SAttendTaskActivitySuccess<<<<")
end
return TaskWayOfCoatard.Commit()
