local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local HeroReturnMgr = Lplus.Extend(AwardMgrBase, "HeroReturnMgr")
local def = HeroReturnMgr.define
local instance
def.field("table").returnGameInfo = nil
def.field("number").timerId = 0
def.static("=>", HeroReturnMgr).Instance = function()
  if instance == nil then
    instance = HeroReturnMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgame.SSyncBackGameInfo", HeroReturnMgr.OnSSyncBackGameInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgame.SNotifyBackScoreChange", HeroReturnMgr.OnSNotifyBackScoreChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgame.SGetBackScoreAwardSuccess", HeroReturnMgr.OnSGetBackScoreAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgame.SGetBackScoreAwardFail", HeroReturnMgr.OnSGetBackScoreAwardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgame.SGetBackScoreAwardInfo", HeroReturnMgr.OnSGetBackScoreAwardInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HeroReturnMgr.OnLeaveWorld)
end
def.static("table").OnSSyncBackGameInfo = function(p)
  if _G.IsCrossingServer() then
    return
  end
  if instance.returnGameInfo == nil then
    instance.returnGameInfo = {}
  end
  instance.returnGameInfo.currentPoint = p.current_score_value
  instance.returnGameInfo.indexId = p.current_award_score_index_id
  instance.returnGameInfo.base_day = p.award_day
  instance.returnGameInfo.base_level = p.award_back_game_level
  instance.returnGameInfo.endTime = p.left_time + _G.GetServerTime()
  instance.returnGameInfo.claimedIdx = 0
  local curtime = _G.GetServerTime()
  local stime = require("Main.Common.AbsoluteTimer").GetServerTimeTable(curtime)
  local timecfg = require("Main.Common.TimeCfgUtils").GetTimeCommonCfg(constant.BackGameConsts.scoreResetTime)
  if timecfg then
    if timecfg.activeHour < stime.hour then
      instance.timerId = require("Main.Common.AbsoluteTimer").AddServerTimeEvent(stime.year, stime.month, stime.day + 1, 0, 0, 86400, -1, HeroReturnMgr.Reset, nil)
    else
      instance.timerId = require("Main.Common.AbsoluteTimer").AddServerTimeEvent(stime.year, stime.month, stime.day, timecfg.activeHour, timecfg.activeMinute, 86400, -1, HeroReturnMgr.Reset, nil)
    end
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.HERO_RETURN_AWARD_UPDATE, nil)
  if instance.returnGameInfo.indexId < 0 then
    instance.returnGameInfo.indexId = instance:GetMaxIndex()
    instance.returnGameInfo.claimedIdx = instance.returnGameInfo.indexId
  else
    local lasttime = require("Main.Common.LuaPlayerPrefs").GetRoleNumber("HERO_RETURN_LOGIN_TIME")
    local isshow = lasttime == 0
    if not isshow then
      local last_t = require("Main.Common.AbsoluteTimer").GetServerTimeTable(lasttime)
      local cur_t = require("Main.Common.AbsoluteTimer").GetServerTimeTable(curtime)
      isshow = cur_t.day ~= last_t.day
    end
    if isshow then
      require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.activity[194], function(i, tag)
        if i == 1 then
          local AwardPanel = require("Main.Award.ui.AwardPanel")
          AwardPanel.Instance():ShowPanelEx(AwardPanel.NodeId.HeroReturn)
        end
      end, nil)
      require("Main.Common.LuaPlayerPrefs").SetRoleNumber("HERO_RETURN_LOGIN_TIME", curtime)
    end
    local index_cfg = instance:GetIndexCfg(instance.returnGameInfo.indexId)
    if index_cfg and instance.returnGameInfo.currentPoint >= index_cfg.point then
      gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
    end
  end
end
def.static("table").Reset = function(context)
  if instance.returnGameInfo == nil then
    return
  end
  if instance.returnGameInfo.endTime:ToNumber() <= _G.GetServerTime() then
    instance.returnGameInfo = nil
    if instance.timerId > 0 then
      require("Main.Common.AbsoluteTimer").RemoveListener(instance.timerId)
    end
  else
    instance.returnGameInfo.currentPoint = 0
    instance.returnGameInfo.indexId = 1
    instance.returnGameInfo.claimedIdx = 0
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.HERO_RETURN_AWARD_UPDATE, nil)
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  if instance.timerId > 0 then
    require("Main.Common.AbsoluteTimer").RemoveListener(instance.timerId)
  end
  instance.returnGameInfo = nil
end
def.static("table").OnSNotifyBackScoreChange = function(p)
  if instance.returnGameInfo == nil then
    return
  end
  instance.returnGameInfo.currentPoint = p.now_back_score
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.HERO_RETURN_AWARD_UPDATE, nil)
  local index_cfg = instance:GetIndexCfg(instance.returnGameInfo.indexId)
  if index_cfg and instance.returnGameInfo.currentPoint >= index_cfg.point then
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
  end
end
def.static("table").OnSGetBackScoreAwardSuccess = function(p)
  if instance.returnGameInfo == nil then
    return
  end
  instance.returnGameInfo.claimedIdx = instance.returnGameInfo.indexId
  local nextId = instance.returnGameInfo.indexId + 1
  local cfg = instance:GetIndexCfg(nextId)
  if cfg then
    instance.returnGameInfo.indexId = nextId
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.backgame.CGetBackScoreAwardInfo").new())
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.HERO_RETURN_AWARD_UPDATE, nil)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_MESSAGE_UPDATE, {
    AwardPanel.NodeId.HeroReturn
  })
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
end
def.static("table").OnSGetBackScoreAwardFail = function(p)
  if p.result == p.ACTIVITY_CLOSE then
    Toast(textRes.activity[190])
  end
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  if instance.returnGameInfo == nil then
    return false
  end
  if instance.returnGameInfo.indexId == instance.returnGameInfo.claimedIdx then
    return false
  end
  local cfg = instance:GetIndexCfg(instance.returnGameInfo.indexId)
  if cfg == nil then
    return false
  end
  return instance.returnGameInfo.currentPoint >= cfg.point
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  if self:IsHaveNotifyMessage() then
    return 1
  else
    return 0
  end
end
def.override("=>", "boolean").IsOpen = function(self)
  if instance.returnGameInfo == nil then
    return false
  end
  return instance.returnGameInfo.left_time > 0
end
def.method("number", "=>", "table").GetAwardCfg = function(self, level)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HEROBACK_AWARD_CFG, level)
  if record == nil then
    warn("[GetHeroBackAwardCfg]record is nil for id: ", level)
    return nil
  end
  local cfg = {}
  cfg.silver = record:GetIntValue("silver")
  cfg.exp = record:GetIntValue("exp")
  return cfg
end
def.method("number", "=>", "table").GetIndexCfg = function(self, id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_HEROBACK_INDEX_CFG, id)
  if record == nil then
    warn("[GetHeroBackAward_Index_Cfg]record is nil for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.point = record:GetIntValue("score")
  cfg.index = record:GetIntValue("indexValue")
  return cfg
end
def.method("=>", "number").GetMaxIndex = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_HEROBACK_INDEX_CFG)
  local size = DynamicDataTable.GetRecordsCount(entries)
  local record = DynamicDataTable.GetRecordByIdx(entries, size - 1)
  if record then
    return record:GetIntValue("indexId")
  end
  return -1
end
def.static("table").OnSGetBackScoreAwardInfo = function(p)
  if instance.returnGameInfo then
    instance.returnGameInfo.awardExp = p.exp_value
    instance.returnGameInfo.awardMoney = p.silver_value
    local dlg = require("Main.Award.ui.HeroReturnNode").GetDlg()
    if dlg then
      dlg:SetAwardValue()
    end
  end
end
return HeroReturnMgr.Commit()
