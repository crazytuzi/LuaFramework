local Lplus = require("Lplus")
local SubtaskBase = require("Main.Soaring.proxy.SubtaskBase")
local TaskAncientSeal = Lplus.Extend(SubtaskBase, "TaskAncientSeal")
local AncientSealData = require("Main.Soaring.data.AncientSealData")
local def = TaskAncientSeal.define
local instance
def.field("table")._cfgData = nil
def.const("number").ACTIVITY_ID = constant.CFeiShengConsts.SHANG_GONG_FENG_YIN_ACTIVITY_CFG_ID
def.static("=>", TaskAncientSeal).Instance = function()
  if instance == nil then
    instance = TaskAncientSeal()
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
  local itemInfo = self._cfgData:GetNeedsItems()
  local itemId = itemInfo and itemInfo[1].item_cfg_id or -1
  local cfgNeedNum = itemInfo and itemInfo[1].item_num or 99999
  self:Release()
  if serviceId == npcSrvcId then
    local SoaringModule = require("Main.Soaring.SoaringModule")
    if not SoaringModule.CanJoinActivity() then
      return true
    end
    local bIsCompleted = SoaringModule.GetActivityCompletedByActId(TaskAncientSeal.ACTIVITY_ID)
    if bIsCompleted then
      Toast(textRes.Soaring.AncientSeal[3])
    else
      local UIAncientSeal = require("Main.Soaring.ui.UIAncientSeal")
      local objUI = UIAncientSeal.Instance()
      objUI:ShowPanel(itemId, cfgNeedNum)
    end
    return true
  end
  return false
end
local fx
def.method().DisplayMapEffect = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskAncientSeal.ACTIVITY_ID) then
    return
  end
  self:_loadData()
  local effectInfo = self._cfgData:GetEffectInfo()
  self:Release()
  fx = SoaringModule.PlayMapEffect(effectInfo.effectId, effectInfo.x, effectInfo.y)
end
def.method().UpdateNPCState = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskAncientSeal.ACTIVITY_ID) then
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
  require("Main.Soaring.SoaringModule").ShowTalk(npcid, talkContent, triedTime, TaskAncientSeal)
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
  local desc = textRes.Soaring.AncientSeal[4]:format(npcCfg.npcName)
  local duration = require("Main.Soaring.SoaringModule").ACTFINISH_UI_DURATION
  require("Main.Marriage.ui.MarryNotice").ShowMarryNotice(desc, duration)
  self:Release()
end
def.method()._loadData = function(self)
  if self._cfgData == nil or self._cfgData:IsNil() then
    self._cfgData = AncientSealData.Instance()
    self._cfgData:InitData(TaskAncientSeal.ACTIVITY_ID)
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
def.static().RegisterTaskClass = function()
  local SoaringModule = require("Main.Soaring.SoaringModule")
  SoaringModule.RegisterTaskClass(TaskAncientSeal.ACTIVITY_ID, TaskAncientSeal)
end
def.static().SendCommitItemReq = function()
  warn(">>>>Send CAttendCommitItemActivityReq <<<<")
  local p = require("netio.protocol.mzm.gsp.feisheng.CAttendCommitItemActivityReq").new(TaskAncientSeal.ACTIVITY_ID)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSAttendCommitItemActivityFail = function(p)
  if p.activity_cfg_id == TaskAncientSeal.ACTIVITY_ID then
    warn(">>>>SAttendCommitItemActivityFail<<<<")
    if p.res == -1 then
      warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
    elseif p.res == -2 then
      warn(">>>>ROLE_STATUS_ERROR<<<")
    elseif p.res == -3 then
      warn(">>>>PARAM_ERROR<<<<")
    elseif p.res == -4 then
      warn(">>>>CHECK_NPC_SERVICE_ERROR<<<<")
    elseif p.res == 1 then
      warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
    elseif p.res == 2 then
      Toast(textRes.Soaring.AncientSeal[1])
    elseif p.res == 3 then
      warn(">>>>AWARD_FAIL<<<<")
    end
  end
end
def.static("table").OnSAttendCommitItemActivitySuccess = function(p)
  if p.activity_cfg_id == TaskAncientSeal.ACTIVITY_ID then
    Event.DispatchEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.ANCIENTSEAL_COMMIT_SUCCESS, nil)
  end
end
return TaskAncientSeal.Commit()
