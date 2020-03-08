local Lplus = require("Lplus")
local AntiAddictionMgr = Lplus.Class("AntiAddictionMgr")
local ECPanelBase = require("GUI.ECPanelBase")
local def = AntiAddictionMgr.define
local instance
def.field("number").timerId = 0
def.field("boolean").isOperate = false
def.static("=>", AntiAddictionMgr).Instance = function()
  if instance == nil then
    instance = AntiAddictionMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.addiction.SReportOnlineTimeSuccess", AntiAddictionMgr.OnSReportOnlineTimeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.addiction.SKickOutInfo", AntiAddictionMgr.OnSKickOutInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, AntiAddictionMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, AntiAddictionMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_LEADER_CLICK_SCREEN, AntiAddictionMgr.OnScreenHandler)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, AntiAddictionMgr.OnFunctionOpenChange)
  ECPanelBase.AddEventHook("onClick", AntiAddictionMgr.OnClickHandler)
  ECPanelBase.AddEventHook("onClickObj", AntiAddictionMgr.OnClickObjHandler)
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  instance:setAntiAddictionTimer()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  if instance.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(instance.timerId)
    instance.timerId = 0
  end
  instance.isOperate = false
end
def.static("table", "table").OnScreenHandler = function(p1, p2)
  warn("--------OnScreenHandler:")
  instance:setOperationFlag()
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local addictionId = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ADDICTION
  if p1.feature == addictionId then
    if _G.IsFeatureOpen(addictionId) then
      instance:setAntiAddictionTimer()
    else
      if instance.timerId ~= 0 then
        GameUtil.RemoveGlobalTimer(instance.timerId)
        instance.timerId = 0
        warn("---------OnFunctionOpenChange remove Antiaddiction timerId")
      end
      instance.isOperate = false
    end
  end
end
def.static("table", "string", "varlist", "=>", "boolean").OnPressHandler = function(sender, id)
  warn("--------OnPressHandler:", id)
  instance:setOperationFlag()
  return true
end
def.static("table", "string", "varlist", "=>", "boolean").OnClickHandler = function(sender, id)
  warn("--------OnClickHandler:", id)
  instance:setOperationFlag()
  return true
end
def.static("table", "userdata", "table", "table", "table").OnClickObjHandler = function(sender, id)
  warn("--------OnClickObjHandler:", id)
  instance:setOperationFlag()
end
def.static("table").OnSReportOnlineTimeSuccess = function(p)
  warn("------------OnSReportOnlineTimeSuccess:", p.remind)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ADDICTION) then
    return
  end
  if p.remind == 1 then
    local hours = math.floor(p.left_time / 3600)
    local mins = math.floor((p.left_time - hours * 3600) / 60)
    local timeStr
    if hours > 0 then
      timeStr = hours .. textRes.AntiAddiction[16] .. mins .. textRes.AntiAddiction[17]
    elseif mins > 0 then
      timeStr = mins .. textRes.AntiAddiction[17]
    else
      timeStr = p.left_time .. textRes.AntiAddiction[18]
    end
    local onlineHours = math.floor(p.online_time / 3600)
    local onlineMins = math.floor((p.online_time - onlineHours * 3600) / 60)
    local onlineStr = onlineHours .. textRes.AntiAddiction[16] .. onlineMins .. textRes.AntiAddiction[17]
    local content
    if p.remind_type == p.ONLINE_TIME then
      content = string.format(textRes.AntiAddiction[19], onlineStr, timeStr)
    else
      content = string.format(textRes.AntiAddiction[20], onlineStr, timeStr)
    end
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowCerternConfirm("", content, "", nil, nil)
  end
end
def.static("table").OnSKickOutInfo = function(p)
  warn("--------OnSKickOutInfo:", p.identity, p.kickout_type, p.online_time, p.total_online_time, p.rest_time)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ADDICTION) then
    return
  end
  local promoteText = ""
  local onlineHours = math.floor(p.online_time / 3600)
  local totalHours = math.floor(p.total_online_time / 3600)
  local restMin = math.floor(p.rest_time / 60)
  if p.identity == 0 then
    if p.kickout_type == p.ONLINE_TIME then
      promoteText = string.format(textRes.AntiAddiction[12], onlineHours, restMin)
    elseif p.kickout_type == p.TOTAL_ONLINE_TIME then
      promoteText = string.format(textRes.AntiAddiction[14], totalHours, restMin)
    elseif p.kickout_type == p.SPILL_ONLINE_TIME then
      promoteText = string.format(textRes.AntiAddiction[15], totalHours, restMin)
    end
  elseif p.kickout_type == p.ONLINE_TIME then
    promoteText = string.format(textRes.AntiAddiction[11], onlineHours, restMin)
  elseif p.kickout_type == p.TOTAL_ONLINE_TIME then
    promoteText = string.format(textRes.AntiAddiction[13], totalHours, restMin)
  elseif p.kickout_type == p.SPILL_ONLINE_TIME then
    promoteText = string.format(textRes.AntiAddiction[15], totalHours, restMin)
  end
  gmodule.network.disConnect()
  gmodule.moduleMgr:GetModule(ModuleId.LOGIN):ShowConnectLostDlg(p.reason, promoteText)
end
def.method().setAntiAddictionTimer = function(self)
  if self.timerId == 0 then
    self.timerId = GameUtil.AddGlobalTimer(constant.CAddictionConsts.HEART_BEAT_SECOND, false, function()
      self:reportOnlineTime()
    end)
  else
    warn("------timerId:", self.timerId)
  end
end
def.method().reportOnlineTime = function(self)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ADDICTION) then
    return
  end
  warn("-------reportOnlineTime:", self.isOperate)
  local state = 1
  if not self.isOperate then
    state = 0
  end
  local p = require("netio.protocol.mzm.gsp.addiction.CReportOnlineTime").new(state)
  gmodule.network.sendProtocol(p)
  self.isOperate = false
end
def.method().setOperationFlag = function(self)
  if not self.isOperate then
    self.isOperate = true
  end
end
return AntiAddictionMgr.Commit()
