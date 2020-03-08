local Lplus = require("Lplus")
local ActivityInterface = require("Main.activity.ActivityInterface")
local TreasureHuntUtils = require("Main.activity.TreasureHunt.TreasureHuntUtils")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local NPCInterface = require("Main.npc.NPCInterface")
local CommonActivityPanel = require("GUI.CommonActivityPanel")
local TopPanel = require("Main.activity.TreasureHunt.ui.TreasureHuntTopPanel")
local TreasureHuntMgr = Lplus.Class("TreasureHuntMgr")
local def = TreasureHuntMgr.define
local instance
def.static("=>", TreasureHuntMgr).Instance = function()
  if nil == instance then
    instance = TreasureHuntMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, TreasureHuntMgr.OnNpcService)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, TreasureHuntMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TreasureHuntMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, TreasureHuntMgr.OnActivityTodo)
  self:RegisterActivityNpcService()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.treasurehunt.SAttendTreasureHuntSuccess", TreasureHuntMgr.OnSAttendTreasureHuntSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.treasurehunt.SLeaveTreasureHuntSuccess", TreasureHuntMgr.OnSLeaveTreasureHuntSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.treasurehunt.SNotifyTreasureHuntProcess", TreasureHuntMgr.OnSNotifyTreasureHuntProcess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.treasurehunt.SSyncTreasureHuntInfo", TreasureHuntMgr.OnSSyncTreasureHuntInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.treasurehunt.SNotifyTreasureHuntSuccess", TreasureHuntMgr.OnSNotifyTreasureHuntSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.treasurehunt.SNotifyReduceTreasureHuntTime", TreasureHuntMgr.OnSNotifyReduceTreasureHuntTime)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.treasurehunt.STreasureHuntNormalFail", TreasureHuntMgr.OnSTreasureHuntNormalFail)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TreasureHuntMgr.onLeaveWorld)
end
def.static("table").OnSTreasureHuntNormalFail = function(p)
  Toast(textRes.TreasureHunt.STreasureHuntNormalFail[p.result])
end
def.static("table").OnSAttendTreasureHuntSuccess = function(p)
  local self = TreasureHuntMgr.Instance()
  local totalGiftNum = p.total
  local leftTime = p.left_seconds
  local chapterId = p.chapter_cfg_id
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Treasure_Hunt_Enter, nil)
  self:ShowExitAndTopUI(leftTime, totalGiftNum, totalGiftNum, chapterId)
end
def.static("table").OnSNotifyReduceTreasureHuntTime = function(p)
  local reducedTime = p.reduce_seconds
  local leftTime = p.left_seconds
  Toast(string.format(textRes.TreasureHunt[4], reducedTime))
  local currTime = _G.GetServerTime()
  local endTime = currTime + leftTime
  TopPanel.Instance():StartCountDown(endTime)
end
def.static("table").OnSNotifyTreasureHuntSuccess = function(p)
  TopPanel.Instance():DestroyPanel()
  Toast(textRes.TreasureHunt[5])
  local effectId = p.effect_id
  if effectId ~= 0 then
    local effectCfg = GetEffectRes(effectId)
    if nil == effectCfg then
      warn(string.format("treasure hunt effet cfg is nil id: %d", effectId))
      return
    end
    local GUIFxMan = require("Fx.GUIFxMan")
    local fx = GUIFxMan.Instance():Play(effectCfg.path, "GetBaby", 0, 0, -1, false)
  end
end
def.method("number", "number", "number", "number").ShowExitAndTopUI = function(self, leftTime, leftGiftNum, totalGiftNum, chapterId)
  CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, function()
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.TreasureHunt[1], function(sel)
      if sel == 1 then
        self:LeaveTreasureHunt()
      end
    end, nil)
  end, nil, false, CommonActivityPanel.ActivityType.TREASURE_HUNT)
  local currTime = _G.GetServerTime()
  local endTime = currTime + leftTime
  TopPanel.Instance():ShowPanel(endTime, leftGiftNum, totalGiftNum, chapterId)
end
def.static("table").OnSNotifyTreasureHuntProcess = function(p)
  local openedGiftNum = p.process
  local totalGiftNum = p.total
  TopPanel.Instance():SetGift(totalGiftNum - openedGiftNum, totalGiftNum)
end
def.static("table").OnSSyncTreasureHuntInfo = function(p)
  local openedGiftNum = p.process
  local totalGiftNum = p.total
  local leftGiftNum = totalGiftNum - openedGiftNum
  local leftTime = p.left_seconds
  local chapterId = p.chapter_cfg_id
  local self = TreasureHuntMgr.Instance()
  if leftTime > 0 then
    self:ShowExitAndTopUI(leftTime, leftGiftNum, totalGiftNum, chapterId)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Treasure_Hunt_Enter, nil)
  end
end
def.method().LeaveTreasureHunt = function(self)
  local activityId = TreasureHuntUtils.GetActivityId()
  if activityId ~= 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.treasurehunt.CLeaveTreasureHunt").new(activityId))
  end
end
def.static("table").OnSLeaveTreasureHuntSuccess = function(p)
  local activityId = p[1]
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Treasure_Hunt_Leave, {activityId})
  CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.TREASURE_HUNT)
  TopPanel.Instance():DestroyPanel()
end
def.static("table", "table").OnNpcService = function(p1, p2)
  local serviceId = p1[1]
  local npcId = p1[2]
  local activityId = TreasureHuntUtils.GetActivityIdByNpcIdAndServiceId(npcId, serviceId)
  if activityId ~= 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.treasurehunt.CAttendTreasureHunt").new(activityId))
  end
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  local activityInfo = TreasureHuntUtils.GetTreasureHuntByActivityId(activityId)
  if activityInfo ~= nil then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      activityInfo.npcId
    })
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local self = TreasureHuntMgr.Instance()
  self:UpdateActivityIDIPState()
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
  local featureType = p1.feature
  if featureType == Feature.TYPE_CHRISTMAS_TREASURE_HUNT or TreasureHuntUtils.IsTreasureHuntIDIP(featureType) then
    local self = TreasureHuntMgr.Instance()
    self:UpdateActivityIDIPState()
  end
end
def.method().UpdateActivityIDIPState = function(self)
  local activityIDIPCfg = TreasureHuntUtils.GetTreasureHuntActivityIdAndIDIP()
  for idx, cfg in pairs(activityIDIPCfg) do
    if _G.IsFeatureOpen(Feature.TYPE_CHRISTMAS_TREASURE_HUNT) then
      if _G.IsFeatureOpen(cfg.featureId) then
        ActivityInterface.Instance():removeCustomCloseActivity(cfg.activityId)
      else
        ActivityInterface.Instance():addCustomCloseActivity(cfg.activityId)
      end
    else
      ActivityInterface.Instance():addCustomCloseActivity(cfg.activityId)
    end
  end
end
def.method().RegisterActivityNpcService = function(self)
  local npcInterface = NPCInterface.Instance()
  local allActivity = TreasureHuntUtils.GetAllActivity()
  for idx, activityCfg in pairs(allActivity) do
    npcInterface:RegisterNPCServiceCustomCondition(activityCfg.npcServiceId, TreasureHuntMgr.OnNpcServiceCheck)
  end
end
def.static("number", "=>", "boolean").OnNpcServiceCheck = function(serviceId)
  local featureId = TreasureHuntUtils.GetIDIPByNpcServiceId(serviceId)
  if featureId == 0 then
    return false
  end
  return _G.IsFeatureOpen(Feature.TYPE_CHRISTMAS_TREASURE_HUNT) and _G.IsFeatureOpen(featureId)
end
def.static("table", "table").onLeaveWorld = function(p1, p2)
  TopPanel.Instance():DestroyPanel()
end
TreasureHuntMgr.Commit()
return TreasureHuntMgr
