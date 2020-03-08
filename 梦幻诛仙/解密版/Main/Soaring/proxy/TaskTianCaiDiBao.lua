local Lplus = require("Lplus")
local SubtaskBase = require("Main.Soaring.proxy.SubtaskBase")
local TaskTianCaiDiBao = Lplus.Extend(SubtaskBase, "TaskTianCaiDiBao")
local AncientSealData = require("Main.Soaring.data.AncientSealData")
local def = TaskTianCaiDiBao.define
local instance
def.field("table")._cfgData = nil
def.const("number").ACTIVITY_ID = constant.CFeiShengConsts.TIAN_CAI_DI_BAO_ACTIVITY_CFG_ID
def.static("=>", TaskTianCaiDiBao).Instance = function()
  if instance == nil then
    instance = TaskTianCaiDiBao()
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
  self:Release()
  if serviceId == npcSrvcId then
    local SoaringModule = require("Main.Soaring.SoaringModule")
    if not SoaringModule.CanJoinActivity() then
      return true
    end
    local ActivityInterface = require("Main.activity.ActivityInterface")
    if not ActivityInterface.CheckActivityConditionFinishCount(TaskTianCaiDiBao.ACTIVITY_ID) then
      Toast(textRes.Soaring.TianCaiDiBao[3])
      return true
    end
    if ActivityInterface.Instance():isActivityOpend(TaskTianCaiDiBao.ACTIVITY_ID) then
      require("Main.Soaring.ui.UITianCaiDiBao").Instance():ShowPanel()
    else
      Toast(textRes.Soaring.TianCaiDiBao[2])
    end
    return true
  end
  return false
end
local fx
def.method().DisplayMapEffect = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskTianCaiDiBao.ACTIVITY_ID) then
    return
  end
  self:_loadData()
  local effectInfo = self._cfgData:GetEffectInfo()
  self:Release()
  fx = SoaringModule.PlayMapEffect(effectInfo.effectId, effectInfo.x, effectInfo.y)
end
def.method().UpdateNPCState = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskTianCaiDiBao.ACTIVITY_ID) then
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
  require("Main.Soaring.SoaringModule").ShowTalk(npcid, talkContent, triedTime, TaskTianCaiDiBao)
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
  local desc = textRes.Soaring.TianCaiDiBao[4]:format(npcCfg.npcName)
  local duration = require("Main.Soaring.SoaringModule").ACTFINISH_UI_DURATION
  require("Main.Marriage.ui.MarryNotice").ShowMarryNotice(desc, duration)
  self:Release()
end
def.method()._loadData = function(self)
  if self._cfgData == nil or self._cfgData:IsNil() then
    self._cfgData = AncientSealData.Instance()
    self._cfgData:InitData(TaskTianCaiDiBao.ACTIVITY_ID)
  end
end
def.override().Release = function(self)
  if self._cfgData ~= nil then
    self._cfgData:Release()
    self._cfgData = nil
  end
end
def.static("number", "=>", "table").FastGetCfgData = function(actId)
  local cfgData = AncientSealData.Instance()
  cfgData:InitData(actId)
  local retData = {}
  retData.npc_id = cfgData:GetNPCId()
  cfgData:Release()
  return retData
end
def.method("=>", "table").GetCfgData = function(self)
  self:_loadData()
  return self._cfgData
end
def.static().RegisterTaskClass = function()
  local SoaringModule = require("Main.Soaring.SoaringModule")
  SoaringModule.RegisterTaskClass(TaskTianCaiDiBao.ACTIVITY_ID, TaskTianCaiDiBao)
end
def.static("table").OnSAttendCommitItemActivityFail = function(p)
end
def.static("table").OnSAttendCommitItemActivitySuccess = function(p)
  if p.activity_cfg_id == TaskTianCaiDiBao.ACTIVITY_ID then
    local UITianCaiDiBao = require("Main.Soaring.ui.UITianCaiDiBao").Instance()
    if UITianCaiDiBao.m_panel and UITianCaiDiBao:IsShow() then
      UITianCaiDiBao:PlayEffect()
    end
  end
end
return TaskTianCaiDiBao.Commit()
