local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local ParticipateActivity = Lplus.Extend(Operation, CUR_CLASS_NAME)
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = ParticipateActivity.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local activityId = params[1] and tonumber(params[1]) or 0
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local myHero = require("Main.Hero.HeroModule").Instance()
  local heroProp = myHero:GetHeroProp()
  local myLevel = heroProp.level
  if activityCfg and myLevel < activityCfg.levelMin then
    Toast(string.format(textRes.activity[383], activityCfg.levelMin))
    return false
  end
  if not ActivityInterface.Instance():isActivityOpend(activityId) then
    local state = ActivityInterface.GetActivityState(activityId)
    if state < 0 then
      Toast(textRes.activity[270])
      return false
    end
    if state > 0 then
      Toast(textRes.activity[271])
      return false
    end
    warn(string.format("OnParticipateActivity(%d) Exception: Maybe activity is force pause or force close"))
    Toast(textRes.activity[271])
    return false
  end
  GameUtil.AddGlobalTimer(0, true, function()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {activityId})
  end)
  return true
end
return ParticipateActivity.Commit()
