local Lplus = require("Lplus")
local SubtaskBase = require("Main.Soaring.proxy.SubtaskBase")
local TaskZhuXianJianZhen = Lplus.Extend(SubtaskBase, "TaskZhuXianJianZhen")
local ZhuXianJianZhenData = require("Main.Soaring.data.ZhuXianJianZhenData")
local UIZhuXianJianZhen = require("Main.Soaring.ui.UIZhuXianJianZhen")
local UIZhuXianJianZhenCountdown = require("Main.Soaring.ui.UIZhuXianJianZhenCountdown")
local GUIFxMan = require("Fx.GUIFxMan")
local def = TaskZhuXianJianZhen.define
local instance
local G_iHasTriedTimes = 0
def.field("table")._cfgData = nil
def.const("number").ACTIVITY_ID = constant.CFeiShengConsts.ZHU_XIAN_JIAN_ZHEN_ACTIVITY_CFG_ID
def.static("=>", TaskZhuXianJianZhen).Instance = function()
  if instance == nil then
    instance = TaskZhuXianJianZhen()
  end
  return instance
end
def.override().OnTodoTask = function(self)
  self:_loadData()
  local npc_id = self._cfgData:GetNPCId()
  self:Release()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npc_id})
end
def.override("number", "number", "=>", "boolean").OnDoTask = function(self, npcid, serviceId)
  self:_loadData()
  local npcServiceId = self._cfgData:GetNPCServiceId()
  local commitItemSrvcId = self._cfgData:GetCommitNPCServiceId()
  local daiyMaxTryTimesCfg = self._cfgData:GetMaxTryTimes()
  self:Release()
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if serviceId == npcServiceId then
    if not SoaringModule.CanJoinActivity() then
      return true
    end
    local bIsCompleted = require("Main.Soaring.SoaringModule").GetActivityCompletedByActId(TaskZhuXianJianZhen.ACTIVITY_ID)
    if bIsCompleted then
      Toast(textRes.Soaring.ZhuXianJianZhen[11])
    elseif daiyMaxTryTimesCfg <= G_iHasTriedTimes then
      Toast(textRes.Soaring.ZhuXianJianZhen[12])
    else
      TaskZhuXianJianZhen.SendAttendZhuXianJianZhenActivityReq()
    end
    return true
  elseif serviceId == commitItemSrvcId then
    if not SoaringModule.CanJoinActivity() then
      return true
    end
    TaskZhuXianJianZhen.SendCommitItemInZhuXianJianZhenReq()
    return true
  end
  return false
end
local fx
def.method().DisplayMapEffect = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskZhuXianJianZhen.ACTIVITY_ID) then
    return
  end
  self:_loadData()
  local effectInfo = self._cfgData:GetEffectInfo()
  self:Release()
  fx = SoaringModule.PlayMapEffect(effectInfo.effectId, effectInfo.x, effectInfo.y)
end
def.method().UpdateNPCState = function(self)
  local SoaringModule = require("Main.Soaring.SoaringModule")
  if not SoaringModule.GetActivityCompletedByActId(TaskZhuXianJianZhen.ACTIVITY_ID) then
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
  require("Main.Soaring.SoaringModule").ShowTalk(npcid, talkContent, triedTime, TaskZhuXianJianZhen)
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
  local desc = textRes.Soaring.ZhuXianJianZhen[13]:format(npcCfg.npcName)
  local duration = require("Main.Soaring.SoaringModule").ACTFINISH_UI_DURATION
  require("Main.Marriage.ui.MarryNotice").ShowMarryNotice(desc, duration)
  self:Release()
end
def.method()._loadData = function(self)
  if self._cfgData == nil or self._cfgData:IsNil() then
    self._cfgData = ZhuXianJianZhenData.Instance()
    self._cfgData:InitData(TaskZhuXianJianZhen.ACTIVITY_ID)
  end
end
def.override().Release = function(self)
  if self._cfgData ~= nil then
    self._cfgData:Release()
    self._cfgData = nil
  end
end
def.static("number", "=>", "table").FastGetCfgData = function(actId)
  local cfgData = ZhuXianJianZhenData.Instance()
  cfgData:InitData(actId)
  local retData = {}
  retData.npc_id = cfgData:GetNPCId()
  cfgData:Release()
  return retData
end
def.static().RegisterTaskClass = function()
  local SoaringModule = require("Main.Soaring.SoaringModule")
  SoaringModule.RegisterTaskClass(TaskZhuXianJianZhen.ACTIVITY_ID, TaskZhuXianJianZhen)
end
def.static().SendAttendZhuXianJianZhenActivityReq = function()
  warn(">>>>Send AttendZhuXianJianZhenActivityReq<<<<")
  local p = require("netio.protocol.mzm.gsp.feisheng.CAttendZhuXianJianZhenActivityReq").new(TaskZhuXianJianZhen.ACTIVITY_ID)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSAttendZhuXianJianZhenActivityFail = function(p)
  warn(">>>>SAttendZhuXianJianZhenActivityFail<<<<")
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>CHECK_NPC_SERVICE_ERROR<<<<")
  elseif p.res == -5 then
    warn(">>>>SERVER_LEVEL_NOT_ENOUGH<<<<")
  elseif p.res == -6 then
    warn(">>>>DB_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == 2 then
    warn(">>>>TRY_TIMES_TO_LIMIT<<<<")
    Toast(textRes.Soaring.ZhuXianJianZhen[12])
  elseif p.res == 3 then
    warn(">>>>AWARD_FAIL<<<<")
  elseif p.res == 4 then
    warn(">>>>ROLE_IN_TEAM<<<<")
    Toast(textRes.Soaring.ZhuXianJianZhen[2])
  elseif p.res == 5 then
    warn(">>>>ACTIVITY_STAGE_ERROR<<<<")
  end
end
def.static().SendCommitItemInZhuXianJianZhenReq = function()
  warn(">>>>Send AttendZhuXianJianZhenActivityReq<<<<")
  local p = require("netio.protocol.mzm.gsp.feisheng.CCommitItemInZhuXianJianZhenActivityReq").new(TaskZhuXianJianZhen.ACTIVITY_ID)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSCommitItemInZhuXianJianZhenActivityFail = function(p)
  warn(">>>>SCommitItemInZhuXianJianZhenActivityFail<<<<")
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>CHECK_NPC_SERVICE_ERROR<<<<")
  elseif p.res == -5 then
    warn(">>>>DB_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == 2 then
    warn(">>>>ITEM_NOT_ENOUGH<<<<")
    Toast(textRes.Soaring.ZhuXianJianZhen[3])
  elseif p.res == 3 then
    warn(">>>>COMMIT_ITEM_NUM_TO_LIMIT<<<<")
  elseif p.res == 4 then
    warn(">>>>ACTIVITY_STAGE_ERROR<<<<")
  end
end
def.static("table").OnSCommitItemInZhuXianJianZhenActivitySuccess = function(p)
  if p.activity_cfg_id == TaskZhuXianJianZhen.ACTIVITY_ID then
    Toast(textRes.Soaring.ZhuXianJianZhen[4])
  end
end
def.static("table").OnSLeaveZhuXianJianZhenActivityMapFail = function(p)
  warn(">>>>SLeaveZhuXianJianZhenActivityMapFail<<<<")
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>CHECK_NPC_SERVICE_ERROR<<<<")
  elseif p.res == -5 then
    warn(">>>>DB_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == 2 then
    warn(">>>>ACTIVITY_STAGE_ERROR<<<<")
  end
end
local StageInfo = require("netio.protocol.mzm.gsp.feisheng.SSynZhuXianJianZhenActivityStageInfo")
def.static("table").OnSSynZhuXianJianZhenActivityStageInfo = function(p)
  if p.activity_cfg_id == TaskZhuXianJianZhen.ACTIVITY_ID then
    warn(">>>>SSynZhuXianJianZhenActivityStageInfo<<<<")
    G_iHasTriedTimes = p.daily_try_times
    if p.stage == 1 then
      TaskZhuXianJianZhen.DoStage_1(p)
    elseif p.stage == 2 then
      TaskZhuXianJianZhen.DoStage_2(p)
    end
  end
end
def.static().LeaveMap = function()
  warn(">>>>Send CLeaveZhuXianJianZhenActivityMapReq<<<<")
  local p = require("netio.protocol.mzm.gsp.feisheng.CLeaveZhuXianJianZhenActivityMapReq").new(TaskZhuXianJianZhen.ACTIVITY_ID)
  gmodule.network.sendProtocol(p)
end
local G_bRcvdBegin = false
def.static("table", "table").OnCrossDay = function(p, context)
  local activityId = p and p[1] or 0
  if activityId ~= TaskZhuXianJianZhen.ACTIVITY_ID then
    return
  end
  TaskZhuXianJianZhen.ResetData()
end
def.static("table", "table").OnLeaveWorld = function(p, context)
  TaskZhuXianJianZhen.ResetData()
end
def.static().ResetData = function()
  G_bRcvdBegin = false
  G_iHasTriedTimes = 0
end
local G_guiFx
def.static("number").DisplayUIEffect = function(effectID)
  TaskZhuXianJianZhen.RemoveGUIEffect()
  local effectPath = _G.GetEffectRes(effectID)
  local effectName = "zhuxianjianzhen"
  G_guiFx = GUIFxMan.Instance():Play(effectPath.path, effectName, 0, 0, -1, true)
end
def.static().RemoveGUIEffect = function()
  if G_guiFx == nil then
    return
  end
  GUIFxMan.Instance():RemoveFx(G_guiFx)
  G_guiFx = nil
end
def.static("table").DoStage_1 = function(p)
  local self = TaskZhuXianJianZhen.Instance()
  if p.state == StageInfo.STATE_BEGIN then
    TaskZhuXianJianZhen.RemoveGUIEffect()
    self:_loadData()
    local uiTip = UIZhuXianJianZhen.Instance()
    local tipsInfo = self._cfgData:GetFirstRoundTipsInfo()
    local tipsContent = require("Main.Common.TipsHelper").GetHoverTip(tipsInfo.tipsId)
    uiTip:SetDuration(tipsInfo.duration)
    uiTip:SetTitle(textRes.Soaring.ZhuXianJianZhen[5])
    uiTip:SetContent(tipsContent)
    G_bRcvdBegin = true
    uiTip:SetTimeoutCallback(TaskZhuXianJianZhen.ShowUICountdown_1(p))
    uiTip:ShowPanel()
  elseif p.state == StageInfo.STATE_RUNNING then
    TaskZhuXianJianZhen.ShowUICountdown_1(p)
  elseif p.state == StageInfo.STATE_END then
    UIZhuXianJianZhenCountdown.Instance():HidePanel()
    if p.result == nil or p.result == 2 then
      Toast(textRes.Soaring.ZhuXianJianZhen[15])
      return
    end
    self:_loadData()
    local effectID = self._cfgData:GetUIEffectId()
    self:Release()
    Toast(textRes.Soaring.ZhuXianJianZhen[14])
    TaskZhuXianJianZhen.DisplayUIEffect(effectID)
  elseif p.state == StageInfo.STAGE_OVER then
  end
  self:Release()
end
def.static("table").DoStage_2 = function(p)
  local self = TaskZhuXianJianZhen.Instance()
  if p.state == StageInfo.STATE_BEGIN then
    TaskZhuXianJianZhen.RemoveGUIEffect()
    self:_loadData()
    local uiTip = UIZhuXianJianZhen.Instance()
    G_bRcvdBegin = true
    local tipsInfo = self._cfgData:GetSecondRoundTipsInfo()
    local tipsContent = require("Main.Common.TipsHelper").GetHoverTip(tipsInfo.tipsId)
    uiTip:SetDuration(tipsInfo.duration)
    uiTip:SetTitle(textRes.Soaring.ZhuXianJianZhen[6])
    uiTip:SetContent(tipsContent)
    uiTip:SetTimeoutCallback(TaskZhuXianJianZhen.ShowUICountdown_2(p))
    uiTip:ShowPanel()
  elseif p.state == StageInfo.STATE_RUNNING then
    TaskZhuXianJianZhen.ShowUICountdown_2(p)
  elseif p.state == StageInfo.STATE_END then
    UIZhuXianJianZhenCountdown.Instance():HidePanel()
    if p.result == nil or p.result == 2 then
      Toast(textRes.Soaring.ZhuXianJianZhen[17])
      return
    end
    self:_loadData()
    local effectID = self._cfgData:GetUIEffectId()
    self:Release()
    Toast(textRes.Soaring.ZhuXianJianZhen[16])
    TaskZhuXianJianZhen.DisplayUIEffect(effectID)
  elseif p.state == StageInfo.STAGE_OVER then
  end
  self:Release()
end
def.static("table", "=>", "table").ShowUICountdown_1 = function(p)
  local self = TaskZhuXianJianZhen.Instance()
  local uiCD = UIZhuXianJianZhenCountdown.Instance()
  self:_loadData()
  local nowSec = _G.GetServerTime()
  local srvStartTime = p.stage_collect_item_start_timestamp
  local tipsInfo = self._cfgData:GetFirstRoundTipsInfo()
  local timePass = nowSec - srvStartTime - tipsInfo.duration
  if timePass < 0 then
    timePass = 0
  end
  local duration = self._cfgData:GetFirstRoundLimitTime() - timePass
  local totalItemNum = self._cfgData:GetFirstRoundDstItemsNum()
  uiCD:SetDuration(duration)
  if not uiCD:IsShow() then
    uiCD:SetStageType(1)
    uiCD:SetTitle(textRes.Soaring.ZhuXianJianZhen[5])
  end
  uiCD:SetContent(textRes.Soaring.ZhuXianJianZhen[8]:format(p.commit_item_num, totalItemNum))
  if not G_bRcvdBegin then
    uiCD:ShowPanel()
  end
  uiCD:UpdateUI()
  return uiCD
end
def.static("table", "=>", "table").ShowUICountdown_2 = function(p)
  local self = TaskZhuXianJianZhen.Instance()
  local uiCD = UIZhuXianJianZhenCountdown.Instance()
  self:_loadData()
  local nowSec = _G.GetServerTime()
  local srvStartTime = p.stage_kill_monster_start_timestamp
  local tipsInfo = self._cfgData:GetSecondRoundTipsInfo()
  local timePass = nowSec - srvStartTime - tipsInfo.duration
  if timePass < 0 then
    timePass = 0
  end
  local duration = self._cfgData:GetSecondRoundLimitTime() - timePass
  local totalMonsterNum = self._cfgData:GetSecondRoundDstNum()
  uiCD:SetDuration(duration)
  if not uiCD:IsShow() then
    uiCD:SetStageType(2)
    uiCD:SetTitle(textRes.Soaring.ZhuXianJianZhen[6])
  end
  uiCD:SetContent(textRes.Soaring.ZhuXianJianZhen[10]:format(p.kill_monster_num, totalMonsterNum))
  if not G_bRcvdBegin then
    uiCD:ShowPanel()
  end
  uiCD:UpdateUI()
  return uiCD
end
def.static("boolean").SetRoleState = function(set)
  if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
    if set then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:SetState(RoleState.ZHUXIANJIANZHEN)
    else
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:RemoveState(RoleState.ZHUXIANJIANZHEN)
    end
  end
end
def.static().ShowActivityBtnWithoutTeam = function()
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, function()
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.Soaring[3], function(sel)
      if sel == 1 then
        TaskZhuXianJianZhen.LeaveMap()
        UIZhuXianJianZhenCountdown.Instance():HidePanel()
        UIZhuXianJianZhen.Instance():HidePanel()
      end
    end, nil)
  end, nil, false, CommonActivityPanel.ActivityType.ZHUXIANJIANZHEN)
end
def.static("table", "table").OnMapChange = function(p, context)
  local self = TaskZhuXianJianZhen.Instance()
  self:_loadData()
  local mapId = p[1]
  local oldMapId = p[2]
  local cfgMapId = self._cfgData:GetMapId()
  if mapId == cfgMapId then
    TaskZhuXianJianZhen.SetRoleState(true)
    TaskZhuXianJianZhen.ShowActivityBtnWithoutTeam()
    Event.DispatchEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.ENTER_ZHUXIANJIANZHEN, nil)
  elseif oldMapId == cfgMapId and mapId ~= cfgMapId then
    local CommonActivityPanel = require("GUI.CommonActivityPanel")
    CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.ZHUXIANJIANZHEN)
    TaskZhuXianJianZhen.SetRoleState(false)
    Event.DispatchEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.QUIT_ZHUXIANJIANZHEN, nil)
    self:Release()
    TaskZhuXianJianZhen.RemoveGUIEffect()
  end
end
return TaskZhuXianJianZhen.Commit()
