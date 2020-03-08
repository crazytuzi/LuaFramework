local Lplus = require("Lplus")
local SubtaskBase = require("Main.Soaring.proxy.SubtaskBase")
local TaskYaoHunXianJi = Lplus.Extend(SubtaskBase, "TaskYaoHunXianJi")
local YaoHunXianJiData = require("Main.Soaring.data.YaoHunXianJiData")
local def = TaskYaoHunXianJi.define
local instance
def.field("table")._cfgData = nil
def.const("number").ACTIVITY_ID = constant.CFeiShengConsts.YAO_HUN_XIAN_JI_ACTIVITY_CFG_ID
def.static("=>", TaskYaoHunXianJi).Instance = function()
  if instance == nil then
    instance = TaskYaoHunXianJi()
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
  local needPetsInfo = self._cfgData:GetNeedPets()
  self:Release()
  if srvcId == serviceId then
    local SoaringModule = require("Main.Soaring.SoaringModule")
    if not SoaringModule.CanJoinActivity() then
      return true
    end
    local bIsCompleted = require("Main.Soaring.SoaringModule").GetActivityCompletedByActId(TaskYaoHunXianJi.ACTIVITY_ID)
    if bIsCompleted then
      Toast(textRes.Soaring.YaoHunXianJi[3])
    else
      local UIYHXJ = require("Main.Soaring.ui.UIYaoHunXianJi")
      local objYHXJ = UIYHXJ.Instance()
      objYHXJ:ShowPanel(needPetsInfo[1].pet_cfg_id, needPetsInfo[1].pet_num)
    end
    return true
  end
  return false
end
local fx
def.method().DisplayMapEffect = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskYaoHunXianJi.ACTIVITY_ID) then
    return
  end
  self:_loadData()
  local effectInfo = self._cfgData:GetEffectInfo()
  self:Release()
  fx = SoaringModule.PlayMapEffect(effectInfo.effectId, effectInfo.x, effectInfo.y)
end
def.method().UpdateNPCState = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskYaoHunXianJi.ACTIVITY_ID) then
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
  require("Main.Soaring.SoaringModule").ShowTalk(npcid, talkContent, triedTime, TaskYaoHunXianJi)
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
  local desc = textRes.Soaring.YaoHunXianJi[4]:format(npcCfg.npcName)
  local duration = require("Main.Soaring.SoaringModule").ACTFINISH_UI_DURATION
  require("Main.Marriage.ui.MarryNotice").ShowMarryNotice(desc, duration)
  self:Release()
end
def.method()._loadData = function(self)
  if self._cfgData == nil or self._cfgData:IsNil() then
    self._cfgData = YaoHunXianJiData.Instance()
    self._cfgData:InitData(TaskYaoHunXianJi.ACTIVITY_ID)
  end
end
def.override().Release = function(self)
  if self._cfgData ~= nil then
    self._cfgData:Release()
    self._cfgData = nil
  end
end
def.static("number", "=>", "table").FastGetCfgData = function(actId)
  local cfgData = YaoHunXianJiData.Instance()
  cfgData:InitData(actId)
  local retData = {}
  retData.npc_id = cfgData:GetNPCId()
  cfgData:Release()
  return retData
end
def.static().RegisterTaskClass = function()
  local SoaringModule = require("Main.Soaring.SoaringModule")
  SoaringModule.RegisterTaskClass(TaskYaoHunXianJi.ACTIVITY_ID, TaskYaoHunXianJi)
end
def.static().SendAttendCommitPetActivityReq = function()
  warn(">>>>>Send CAttendCommitPetActivityReq<<<<")
  local p = require("netio.protocol.mzm.gsp.feisheng.CAttendCommitPetActivityReq").new(TaskYaoHunXianJi.ACTIVITY_ID)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSAttendCommitPetActivitySuccess = function(p)
  if p.activity_cfg_id == TaskYaoHunXianJi.ACTIVITY_ID then
    Event.DispatchEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.YHXJ_COMMIT_SUCCESS, nil)
  end
end
def.static("table").OnSAttendCommitPetActivityFail = function(p)
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
    Toast(textRes.Soaring.YaoHunXianJi[1])
  elseif p.res == 3 then
    warn(">>>>AWARD_FAIL<<<<")
  end
end
return TaskYaoHunXianJi.Commit()
