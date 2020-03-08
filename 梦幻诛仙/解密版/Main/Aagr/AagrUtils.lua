local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ActivityType = require("consts.mzm.gsp.activity.confbean.ActivityType")
local ECPlayer = require("Model.ECPlayer")
local HeroModelMgr = require("Main.Aagr.mgr.HeroModelMgr")
local AttachType = require("consts.mzm.gsp.skill.confbean.EffectGuaDian")
local AagrUtils = Lplus.Class("AagrUtils")
local def = AagrUtils.define
def.static("number", "=>", "boolean").IsActivityOpen = function(activityId)
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  if nil == activityCfg then
    warn("[ERROR][AagrUtils:IsActivityOpen] activityCfg nil for id:", activityId)
    return false
  end
  if ActivityInterface.Instance():IsCustomCloseActivity(activityId) then
    return false
  end
  local isForceOpen = ActivityInterface.Instance():isForceOpenActivity(activityId)
  if isForceOpen then
    return true
  end
  local isForcePause = ActivityInterface.Instance():isActivityPause(activityId)
  if isForcePause then
    return false
  end
  local isForceClose = ActivityInterface.Instance():isForceCloseActivity(activityId)
  if isForceClose then
    return false
  end
  if nil == _G.GetHeroProp() then
    warn("[ERROR][AagrUtils:IsActivityOpen] _G.GetHeroProp() nil.")
    return false
  else
    local myLevel = _G.GetHeroProp().level
    local bLevelValid = myLevel >= activityCfg.levelMin and myLevel <= activityCfg.levelMax
    if false == bLevelValid then
      return false
    end
  end
  if activityCfg.activityType == ActivityType.Daily then
    return true
  end
  local openTime, activeTimeList, closeTime = ActivityInterface.Instance():getActivityStatusChangeTime(activityId)
  local curTime = GetServerTime()
  if openTime > 0 and openTime > curTime or closeTime > 0 and closeTime <= curTime then
    return false
  end
  return true
end
def.static("number", "=>", "boolean").IsInTimeInterval = function(activityId)
  local openTime, activeTimeList, closeTime = ActivityInterface.Instance():getActivityStatusChangeTime(activityId)
  if activeTimeList and #activeTimeList > 0 then
    local result = false
    local curTime = GetServerTime()
    for i, v in ipairs(activeTimeList) do
      warn("[AagrUtils:IsInTimeInterval] beginTime, resetTime, curTime", os.date("%c", v.beginTime), os.date("%c", v.resetTime), os.date("%c", curTime))
      if curTime >= v.beginTime and curTime < v.resetTime and openTime <= v.beginTime then
        result = true
        break
      end
    end
    return result
  else
    return false
  end
end
def.static("string", "number", "=>", "string").GetCountdownText = function(formatStr, countdown)
  local min = 0
  local sec = 0
  if countdown > 0 then
    min = math.floor(countdown / 60)
    sec = countdown % 60
  end
  local result = string.format(formatStr, min, sec)
  return result
end
def.static("number", "table", "=>", "boolean").CheckBallState = function(state, states)
  local result = false
  if states then
    for _, s in pairs(states) do
      if state == s then
        result = true
        break
      end
    end
  end
  return result
end
def.static("userdata", "userdata", "=>", "boolean").IsSameColor = function(color1, color2)
  if color1 and color2 then
    return color1.r == color2.r and color1.g == color2.g and color1.b == color2.b and color1.a == color2.a
  else
    return false
  end
end
def.static(ECPlayer, "number").AddPlayerEffect = function(player, effectId)
  if _G.IsNil(player) then
    warn("[ERROR][AagrUtils:AddPlayerEffect] player nil.")
    return
  end
  local effectCfg = GetEffectRes(effectId)
  if effectCfg then
    player:StopChildEffect(effectCfg.path)
    player:AddChildEffect(effectCfg.path, AttachType.FOOT, "", textRes.Aagr.ROLE_EFFECT_OFFSET)
    HeroModelMgr.Instance():TryAddEffect(player.roleId, effectCfg.path, nil)
  else
    warn("[ERROR][AagrUtils:AddPlayerEffect] effectCfg nil for effectId:", effectId, debug.traceback())
  end
end
def.static(ECPlayer, "number").RemovePlayerEffect = function(player, effectId)
  if _G.IsNil(player) then
    warn("[ERROR][AagrUtils:RemovePlayerEffect] player nil.")
    return
  end
  local effectCfg = GetEffectRes(effectId)
  if effectCfg then
    player:StopChildEffect(effectCfg.path)
    HeroModelMgr.Instance():TryRemoveEffect(player.roleId, effectCfg.path)
  else
    warn("[ERROR][AagrUtils:RemovePlayerEffect] effectCfg nil for effectId:", effectId, debug.traceback())
  end
end
def.static("boolean").TryChangeOtherRoleVisibility = function(bShow)
  if bShow then
    local AagrData = require("Main.Aagr.data.AagrData")
    local arenaInfo = AagrData.Instance():GetArenaInfo()
    local roleMap = arenaInfo and arenaInfo:GetRoleId2NameMap()
    local roleIdStrList
    if roleMap then
      roleIdStrList = {}
      for roleIdStr, _ in pairs(roleMap) do
        table.insert(roleIdStrList, roleIdStr)
      end
    end
    if roleIdStrList and #roleIdStrList > 0 then
      warn("[AagrUtils:TryChangeOtherRoleVisibility] enable visibility.")
      gmodule.moduleMgr:GetModule(ModuleId.PUBROLE).enableSingleMode = false
    else
      warn("[AagrUtils:TryChangeOtherRoleVisibility] enable fail. roleIdStrList nil.")
    end
  else
    warn("[AagrUtils:TryChangeOtherRoleVisibility] disable visibility.")
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE).enableSingleMode = true
  end
end
AagrUtils.Commit()
return AagrUtils
