local Lplus = require("Lplus")
local HistoryData = require("Main.CrossBattle.History.data.HistoryData")
local HistoryUtils = require("Main.CrossBattle.History.HistoryUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local HistoryProtocols
local HistoryMgr = Lplus.Class("HistoryMgr")
local def = HistoryMgr.define
local instance
def.static("=>", HistoryMgr).Instance = function()
  if instance == nil then
    instance = HistoryMgr()
  end
  return instance
end
def.method().Init = function(self)
  HistoryProtocols = require("Main.CrossBattle.History.HistoryProtocols")
  HistoryProtocols.RegisterProtocols()
  HistoryData.Instance():Init()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, HistoryMgr._OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HistoryMgr._OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, HistoryMgr._OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_History_Click, HistoryMgr._OnHistoryClick)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, HistoryMgr._onEnterFight)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, HistoryMgr.OnClickMapFindpath)
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_CROSS_BATTLE_HISTORY) then
    result = false
    if bToast then
      Toast(textRes.CrossBattle.History.FEATRUE_IDIP_NOT_OPEN)
    end
  end
  return result
end
def.method("=>", "boolean").NeedReddot = function(self)
  return false
end
def.static("table", "table")._OnEnterWorld = function(param, context)
  HistoryData.Instance():OnEnterWorld(param, context)
end
def.static("table", "table")._OnLeaveWorld = function(param, context)
  HistoryData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table")._OnFunctionOpenChange = function(param, context)
  if param.feature ~= ModuleFunSwitchInfo.TYPE_CROSS_BATTLE_HISTORY or false == param.open then
  else
  end
end
def.static("table", "table")._OnHistoryClick = function(param, context)
  if HistoryMgr.Instance():IsOpen(true) then
    local HistoryMainPanel = require("Main.CrossBattle.History.ui.HistoryMainPanel")
    HistoryMainPanel.ShowPanel()
  end
end
def.static("table", "table")._onEnterFight = function(param, context)
  local MatchListPanel = require("Main.CrossBattle.History.ui.MatchListPanel")
  if MatchListPanel.Instance():IsShow() then
    MatchListPanel.Instance():DestroyPanel()
  end
  local HistoryMatchPanel = require("Main.CrossBattle.History.ui.HistoryMatchPanel")
  if HistoryMatchPanel.Instance():IsShow() then
    HistoryMatchPanel.Instance():DestroyPanel()
  end
  local HistoryMainPanel = require("Main.CrossBattle.History.ui.HistoryMainPanel")
  if HistoryMainPanel.Instance():IsShow() then
    HistoryMainPanel.Instance():DestroyPanel()
  end
  local CrossBattlePanel = require("Main.CrossBattle.ui.CrossBattlePanel")
  if CrossBattlePanel.Instance():IsShow() then
    warn("[HistoryMgr:_onEnterFight] hide CrossBattlePanel.")
    CrossBattlePanel.Instance():DestroyPanel()
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
HistoryMgr.Commit()
return HistoryMgr
