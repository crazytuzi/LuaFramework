local Lplus = require("Lplus")
local SubtaskBase = require("Main.Soaring.proxy.SubtaskBase")
local TaskQingYunAsked = Lplus.Extend(SubtaskBase, "TaskQingYunAsked")
local UIQingYunAsk = require("Main.Soaring.ui.UIQingYunAsk")
local QingYunAskedData = require("Main.Soaring.data.QingYunAskedData")
local def = TaskQingYunAsked.define
local instance
def.field("table")._cfgData = nil
def.const("number").ACTIVITY_ID = constant.CFeiShengConsts.QING_YUN_WEN_DAO_ACTIVITY_CFG_ID
def.static("=>", TaskQingYunAsked).Instance = function()
  if instance == nil then
    instance = TaskQingYunAsked()
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
  if serviceId == self._cfgData:GetServiceId() then
    local SoaringModule = require("Main.Soaring.SoaringModule")
    if not SoaringModule.CanJoinActivity() then
      return true
    end
    local ActivityInterface = require("Main.activity.ActivityInterface")
    if ActivityInterface.CheckActivityConditionFinishCount(TaskQingYunAsked.ACTIVITY_ID) then
      UIQingYunAsk.Instance():ShowPanel(self._cfgData:GetQingYunZhiType(), self._cfgData:GetChapterId(), self._cfgData:GetSectionId())
    else
      Toast(textRes.Soaring.QingYunAsk[1])
    end
    self:Release()
    return true
  end
  self:Release()
  return false
end
local fx
def.method().DisplayMapEffect = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskQingYunAsked.ACTIVITY_ID) then
    return
  end
  self:_loadData()
  local effectInfo = self._cfgData:GetEffectInfo()
  self:Release()
  fx = SoaringModule.PlayMapEffect(effectInfo.effectId, effectInfo.x, effectInfo.y)
end
def.method().UpdateNPCState = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskQingYunAsked.ACTIVITY_ID) then
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
  require("Main.Soaring.SoaringModule").ShowTalk(npcid, talkContent, triedTime, TaskQingYunAsked)
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
  local desc = textRes.Soaring.QingYunAsk[3]:format(npcCfg.npcName)
  local duration = require("Main.Soaring.SoaringModule").ACTFINISH_UI_DURATION
  require("Main.Marriage.ui.MarryNotice").ShowMarryNotice(desc, duration)
  self:Release()
end
def.method()._loadData = function(self)
  if self._cfgData == nil or self._cfgData:IsNil() then
    self._cfgData = QingYunAskedData.Instance()
    self._cfgData:InitData(TaskQingYunAsked.ACTIVITY_ID)
  end
end
def.override().Release = function(self)
  if self._cfgData ~= nil then
    self._cfgData:Release()
    self._cfgData = nil
  end
end
def.static("number", "=>", "table").FastGetCfgData = function(actId)
  local cfgData = QingYunAskedData.Instance()
  cfgData:InitData(actId)
  local retData = {}
  retData.npc_id = cfgData:GetNPCId()
  cfgData:Release()
  return retData
end
def.static().RegisterTaskClass = function()
  local SoaringModule = require("Main.Soaring.SoaringModule")
  SoaringModule.RegisterTaskClass(TaskQingYunAsked.ACTIVITY_ID, TaskQingYunAsked)
end
def.static("table").OnSAttendQingYunZhiActivityFail = function(p)
  local errorMsg = textRes.Soaring.QingYunAsk.ErrorCode[p.res]
  if errorMsg then
    Toast(errorMsg)
  else
    warn("---------------------OnSAttendQingYunZhiActivityFail", p.res)
  end
end
def.static("table").OnSAttendQingYunZhiActivitySuccess = function(p)
  warn("---------------------OnSAttendQingYunZhiActivitySuccess")
end
return TaskQingYunAsked.Commit()
