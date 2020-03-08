local Lplus = require("Lplus")
local SubtaskBase = require("Main.Soaring.proxy.SubtaskBase")
local TaskRunningXuanGong = Lplus.Extend(SubtaskBase, "TaskRunningXuanGong")
local RunningXuanGongData = require("Main.Soaring.data.RunningXuanGongData")
local def = TaskRunningXuanGong.define
local instance
def.static("=>", TaskRunningXuanGong).Instance = function()
  if instance == nil then
    instance = TaskRunningXuanGong()
  end
  return instance
end
def.const("number").ACTIVITY_ID = constant.CFeiShengConsts.YUN_ZHUAN_XUAN_GONG_ACTIVITY_CFG_ID
def.override().OnTodoTask = function(self)
  local npc_id = self:GetTaskData():GetNPCId()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npc_id})
end
def.method("=>", "table").GetTaskData = function(self)
  return RunningXuanGongData.Instance()
end
def.override("number", "number", "=>", "boolean").OnDoTask = function(self, npcid, serviceId)
  if npcid == self:GetTaskData():GetNPCId() then
    local SoaringModule = require("Main.Soaring.SoaringModule")
    local bIsCompleted = SoaringModule.GetActivityCompletedByActId(TaskRunningXuanGong.ACTIVITY_ID)
    local TaskYZXGMgr = require("Main.Soaring.TaskYZXGMgr")
    if serviceId == self:GetTaskData():GetServiceIdFetchItem() then
      if not SoaringModule.CanJoinActivity() then
        return true
      end
      if bIsCompleted then
        Toast(textRes.Soaring.YZXG[1])
        return true
      end
      if self:GetTaskData():HasItem() then
        require("Main.Soaring.ui.UIRunningXuanGong").Instance():ShowPanel()
      else
        warn("[TaskRunningXuanGong:OnDoTask] onNPCService get item.")
        TaskYZXGMgr.Send_CGetItemInDevelopItemActivityReq()
      end
      return true
    elseif serviceId == self:GetTaskData():GetServiceIdCommitItem() then
      if not SoaringModule.CanJoinActivity() then
        return true
      end
      if bIsCompleted then
        Toast(textRes.Soaring.YZXG[1])
        return true
      end
      warn("[TaskRunningXuanGong:OnDoTask] onNPCService commit item.")
      TaskYZXGMgr.Send_CCommitItemInDevelopItemActivityReq()
      return true
    end
  end
  return false
end
local fx
def.method().DisplayMapEffect = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskRunningXuanGong.ACTIVITY_ID) then
    return
  end
  local effectInfo = self:GetTaskData():GetEffectInfo()
  self:Release()
  fx = SoaringModule.PlayMapEffect(effectInfo.effectId, effectInfo.x, effectInfo.y)
end
def.method().UpdateNPCState = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskRunningXuanGong.ACTIVITY_ID) then
    return
  end
  local npc_id = self:GetTaskData():GetNPCId()
  local talkContent = self:GetTaskData():GetTalkContent()
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
  require("Main.Soaring.SoaringModule").ShowTalk(npcid, talkContent, triedTime, TaskRunningXuanGong)
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
  local npc_id = self:GetTaskData():GetNPCId()
  local npcCfg = NPCInterface.GetNPCCfg(npc_id)
  local desc = textRes.Soaring.YZXG[2]:format(npcCfg.npcName)
  local duration = require("Main.Soaring.SoaringModule").ACTFINISH_UI_DURATION
  require("Main.Marriage.ui.MarryNotice").ShowMarryNotice(desc, duration)
  self:Release()
end
def.override().Release = function(self)
  if self:GetTaskData() ~= nil then
    self:GetTaskData():Release()
  end
end
def.static("number", "=>", "table").FastGetCfgData = function(actId)
  local cfgData = RunningXuanGongData.Instance()
  cfgData:InitData()
  local retData = {}
  retData.npc_id = cfgData:GetNPCId()
  cfgData:Release()
  return retData
end
def.static().RegisterTaskClass = function()
  local SoaringModule = require("Main.Soaring.SoaringModule")
  SoaringModule.RegisterTaskClass(TaskRunningXuanGong.ACTIVITY_ID, TaskRunningXuanGong)
end
return TaskRunningXuanGong.Commit()
