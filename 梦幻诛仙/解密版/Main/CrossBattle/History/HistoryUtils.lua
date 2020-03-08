local Lplus = require("Lplus")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleActivityStage")
local ActivityInterface = require("Main.activity.ActivityInterface")
local GUIUtils = require("GUI.GUIUtils")
local HistoryData = require("Main.CrossBattle.History.data.HistoryData")
local HistoryUtils = Lplus.Class("HistoryUtils")
local def = HistoryUtils.define
def.static("=>", "boolean").IsCrossBattleOver = function()
  local activityId = HistoryData.Instance():GetCurSeasonActivityId()
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  if activityCfg == nil then
    warn("[ERROR][HistoryUtils:IsCrossBattleOver] activityCfg nil for activityId:", activityId)
    return false
  end
  local openTime, activeTimeList, closeTime = ActivityInterface.Instance():getActivityStatusChangeTime(activityId)
  local curTime = GetServerTime()
  if closeTime <= curTime then
    warn(string.format("[HistoryUtils:IsCrossBattleOver] activityId[%d] over=true.", activityId))
    return true
  else
    warn(string.format("[HistoryUtils:IsCrossBattleOver] activityId[%d] over=false.", activityId))
    return false
  end
end
def.static("userdata", "userdata", "userdata", "table").ShowCorpsBriefInfo = function(Img_Badge, Label_TeamName, Label_ServerName, corpsBrief)
  if corpsBrief then
    GUIUtils.SetActive(Img_Badge, true)
    GUIUtils.SetActive(Label_TeamName, true)
    GUIUtils.SetActive(Label_ServerName, true)
    HistoryUtils.SetCorpsIcon(corpsBrief.corps_icon, Img_Badge)
    local serverName = HistoryUtils.GetServerName(corpsBrief.zone_id)
    GUIUtils.SetText(Label_ServerName, serverName)
    local corpsName = _G.GetStringFromOcts(corpsBrief.corps_name)
    GUIUtils.SetText(Label_TeamName, corpsName)
  else
    GUIUtils.SetActive(Img_Badge, false)
    GUIUtils.SetActive(Label_TeamName, false)
    GUIUtils.SetActive(Label_ServerName, false)
  end
end
def.static("number", "userdata").SetCorpsIcon = function(iconId, img)
  if img then
    local CorpsUtils = require("Main.Corps.CorpsUtils")
    local cfg = CorpsUtils.GetCorpsBadgeCfg(iconId)
    if cfg ~= nil then
      GUIUtils.SetActive(img, true)
      GUIUtils.FillIcon(img:GetComponent("UITexture"), cfg.iconId)
    else
      warn("[ERROR][HistoryUtils:SetCorpsIcon] cfg nil for corpsIconId:", iconId)
      GUIUtils.SetActive(img, false)
    end
  end
end
def.static("number", "=>", "string").GetServerName = function(serverId)
  local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(serverId)
  local serverName = serverCfg and serverCfg.name or ""
  return serverName
end
HistoryUtils.Commit()
return HistoryUtils
