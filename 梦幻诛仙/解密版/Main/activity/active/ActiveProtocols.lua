local Lplus = require("Lplus")
local ActiveProtocols = Lplus.Class("ActiveProtocols")
local def = ActiveProtocols.define
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
def.static("table").OnSynActiveDataRes = function(p)
  for k, v in pairs(p.activeDatas) do
    activityInterface._activeDatas[v.activityid] = v.activeCount
  end
  activityInterface._currentTotalActive = 0
  for activityID, times in pairs(activityInterface._activeDatas) do
    local cfg = ActivityInterface.GetActivityCfgById(activityID)
    if cfg ~= nil then
      local res = cfg.awardActiveValue * times
      activityInterface._currentTotalActive = activityInterface._currentTotalActive + res
    end
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, nil)
  for k, id in pairs(p.award_active_index_id_set) do
    activityInterface._awardActiveCfgids[id] = id
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Award_Chged, nil)
end
def.static("table").OnSUpdateActiveDataRes = function(p)
  activityInterface._activeDatas[p.activeData.activityid] = p.activeData.activeCount
  activityInterface._currentTotalActive = 0
  for activityID, times in pairs(activityInterface._activeDatas) do
    local cfg = ActivityInterface.GetActivityCfgById(activityID)
    if cfg ~= nil then
      local res = cfg.awardActiveValue * times
      activityInterface._currentTotalActive = activityInterface._currentTotalActive + res
    end
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, nil)
  local activeAlert = textRes.activity.ActiveAlert
  local serverLevel = require("Main.Server.ServerModule").Instance():GetServerLevelInfo().level
  if activityInterface._currentTotalActive >= activeAlert.NeedActive and serverLevel < activeAlert.CloseSvrLv and serverLevel >= activeAlert.OpenSvrLv then
    local myRoleId = require("Main.Hero.HeroModule").Instance():GetMyRoleId()
    local roleId = Int64.ToNumber(myRoleId)
    local configPath = string.format("%s/config/active_tip_%d.lua", Application.persistentDataPath, roleId)
    local chunk, errorMsg = loadfile(configPath)
    local lastShowTime = 0
    local curTime = GetServerTime()
    if chunk == nil then
      GameUtil.CreateDirectoryForFile(configPath)
    else
      lastShowTime = chunk().lastShowTime
    end
    if lastShowTime == 0 or os.date("%Y%m%d", curTime) ~= os.date("%Y%m%d", lastShowTime) then
      warn("----------------------------------------------show activity alert", os.date("%Y%m%d", curTime), activityInterface._currentTotalActive)
      local content = {}
      table.insert(content, {
        name = textRes.activity[500],
        content = activeAlert.Content1 or ""
      })
      table.insert(content, {
        name = textRes.activity[501],
        content = activeAlert.Content2 or ""
      })
      require("Main.activity.active.ActiveTip").Instance():ShowPanel(content)
      local t = {lastShowTime = curTime}
      require("Main.Common.LuaTableWriter").SaveTable("activeTip", configPath, t)
    end
  end
end
def.static("table").OnSTakeActiveAwardRes = function(p)
  activityInterface._awardActiveCfgids[p.index_id] = p.index_id
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Award_Chged, {
    p.index_id
  })
end
def.static("table").OnSActiveNormalResult = function(p)
  if p.result == p.TAKE_ACTIVE_AWARD_BAG_FULL then
    Toast(string.format(textRes.activity[180]))
  elseif p.result == p.TAKE_ACTIVE_AWARD_TO_MAX then
    Toast(string.format(textRes.activity[181]))
  elseif p.result == p.TAKE_ACTIVE_AWARD_UNKNOW_ERROR then
  end
end
ActiveProtocols.Commit()
return ActiveProtocols
