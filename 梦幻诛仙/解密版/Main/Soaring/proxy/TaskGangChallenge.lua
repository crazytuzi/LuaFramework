local Lplus = require("Lplus")
local SubtaskBase = require("Main.Soaring.proxy.SubtaskBase")
local TaskGangChallenge = Lplus.Extend(SubtaskBase, "TaskGangChallenge")
local UIGangChallenge = require("Main.Soaring.ui.UIGangChallenge")
local GangChallengeData = require("Main.Soaring.data.GangChallengeData")
local def = TaskGangChallenge.define
local instance
def.field("table")._cfgData = nil
def.const("number").ACTIVITY_ID = constant.CFeiShengConsts.MEN_PAI_SHI_LIAN_ACTIVITY_CFG_ID
def.static("=>", TaskGangChallenge).Instance = function()
  if instanc == nil then
    instance = TaskGangChallenge()
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
  local npcSrvcId = self._cfgData:GetNPCServiceId()
  if serviceId == npcSrvcId then
    local SoaringModule = require("Main.Soaring.SoaringModule")
    if not SoaringModule.CanJoinActivity() then
      return true
    end
    local bIsCompleted = SoaringModule.GetActivityCompletedByActId(TaskGangChallenge.ACTIVITY_ID)
    if bIsCompleted then
      Toast(textRes.Soaring.GangChallenge[3])
    else
      local objUIGangChallenge = UIGangChallenge.Instance()
      objUIGangChallenge:SetConfigData(self._cfgData)
      objUIGangChallenge:ShowPanel()
      self._cfgData = nil
    end
    return true
  end
  self:Release()
  return false
end
local fx
def.method().DisplayMapEffect = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskGangChallenge.ACTIVITY_ID) then
    return
  end
  self:_loadData()
  local effectInfo = self._cfgData:GetEffectInfo()
  self:Release()
  fx = SoaringModule.PlayMapEffect(effectInfo.effectId, effectInfo.x, effectInfo.y)
end
def.method().UpdateNPCState = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskGangChallenge.ACTIVITY_ID) then
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
  require("Main.Soaring.SoaringModule").ShowTalk(npcid, talkContent, triedTime, TaskGangChallenge)
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
  local desc = textRes.Soaring.GangChallenge[6]:format(npcCfg.npcName)
  local duration = require("Main.Soaring.SoaringModule").ACTFINISH_UI_DURATION
  require("Main.Marriage.ui.MarryNotice").ShowMarryNotice(desc, duration)
  self:Release()
end
def.method()._loadData = function(self)
  if self._cfgData == nil or self._cfgData:IsNil() then
    self._cfgData = GangChallengeData.Instance()
    self._cfgData:InitData(TaskGangChallenge.ACTIVITY_ID)
  end
end
def.method("=>", "table").GetCfgData = function(self)
  self:_loadData()
  return self._cfgData
end
def.override().Release = function(self)
  if self._cfgData ~= nil then
    self._cfgData:Release()
    self._cfgData = nil
  end
end
def.static("number", "=>", "table").FastGetCfgData = function(actId)
  local cfgData = GangChallengeData.Instance()
  cfgData:InitData(actId)
  local retData = {}
  retData.npc_id = cfgData:GetNPCId()
  cfgData:Release()
  return retData
end
def.static("table").OnSSynFightActivitySchedule = function(p)
  UIGangChallenge.OnSSynFightActivitySchedule(p)
end
def.static("table").OnSAttendFightActivityFail = function(p)
  UIGangChallenge.OnSAttendFightActivityFail(p)
end
def.static().RegisterTaskClass = function()
  local SoaringModule = require("Main.Soaring.SoaringModule")
  SoaringModule.RegisterTaskClass(TaskGangChallenge.ACTIVITY_ID, TaskGangChallenge)
end
def.static("table", "table").OnResetFightActivitySchedule = function(p, context)
  UIGangChallenge.OnResetFightActivitySchedule()
end
def.static("table", "table").OnCrossDay = function(p, context)
  local actId = p[1] and p[1] or 0
  if actId ~= TaskGangChallenge.ACTIVITY_ID then
    return
  end
  UIGangChallenge.OnCrossDay()
end
return TaskGangChallenge.Commit()
