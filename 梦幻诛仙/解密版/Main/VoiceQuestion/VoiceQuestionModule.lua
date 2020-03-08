local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local VoiceQuestionModule = Lplus.Extend(ModuleBase, "VoiceQuestionModule")
local instance
local def = VoiceQuestionModule.define
local Cls = VoiceQuestionModule
local Protocols = require("Main.VoiceQuestion.VoiceQuestionProtocols")
local VoiceQuestionUtils = require("Main.VoiceQuestion.VoiceQuestionUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.VoiceQuestion
def.field("table")._featureList = nil
def.field("table")._srvcId2ActId = nil
def.field("table")._srcActIdList = nil
def.static("=>", VoiceQuestionModule).Instance = function()
  if instance == nil then
    instance = VoiceQuestionModule()
    instance._featureList = VoiceQuestionUtils.LoadFeatureTbl()
  end
  return instance
end
def.override().Init = function(self)
  Protocols.Instance():Init()
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, Cls.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, Cls.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, Cls.OnActivityInfoChanged)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, Cls.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, Cls.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, Cls.OnNPCService)
end
def.static("number", "=>", "number").GetActivityIdBySrvcId = function(srvcId)
  if instance._srvcId2ActId == nil then
    instance._srvcId2ActId = VoiceQuestionUtils.LoadVoiceQuestionSrvcId2ActIds()
  end
  local actId = instance._srvcId2ActId[srvcId]
  return actId or 0
end
def.static("=>", "table").GetSrcActIdList = function()
  if instance._srcActIdList == nil then
    instance._srcActIdList = VoiceQuestionUtils.LoadSrcActIdList()
  end
  return instance._srcActIdList
end
def.static("number", "=>", "boolean", "number").IsActivityFinish = function(actId)
  local activityInfo = ActivityInterface.Instance():GetActivityInfo(actId)
  local actCfgInfo = ActivityInterface.GetActivityCfgById(actId)
  local activityCount = activityInfo and activityInfo.count or 0
  if activityInfo ~= nil and activityInfo.count >= actCfgInfo.limitCount then
    return true, activityCount
  end
  return false, activityCount
end
def.static("=>", "table").GetProtocols = function()
  return Protocols
end
def.static("table", "table").OnFeatureInit = function(p, c)
  Cls._updateActivityInterface()
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  Cls._updateActivityInterface()
end
def.static()._updateActivityInterface = function()
  local activityInterface = ActivityInterface.Instance()
  local featureInstance = FeatureOpenListModule.Instance()
  for actId, openId in pairs(instance._featureList) do
    local bFeatureOpen = featureInstance:CheckFeatureOpen(openId)
    local actCfgInfo = ActivityInterface.GetActivityCfgById(actId)
    local bLvEnough = _G.GetHeroProp().level >= actCfgInfo.levelMin
    if bFeatureOpen and bLvEnough then
      activityInterface:removeCustomCloseActivity(actId)
    else
      activityInterface:addCustomCloseActivity(actId)
    end
  end
end
def.static("table", "table").OnActivityInfoChanged = function(p, c)
  local actId = p[1] and p[1] or 0
  local srcIdList = Cls.GetSrcActIdList()
  for _, srcActId in pairs(srcIdList) do
    if actId == srcActId then
      local bSrcActFinish, _ = Cls.IsActivityFinish(actId)
      if bSrcActFinish then
        do
          local voiceActId = VoiceQuestionUtils.GetDstActivityIdBySrcActId(actId)
          local voiceActCfg = VoiceQuestionUtils.GetVoiceQuestionActCfgByActId(voiceActId)
          CommonConfirmDlg.ShowConfirm(txtConst[4], txtConst[5], function(select)
            if select == 1 then
              Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
                voiceActCfg.npcId
              })
            end
          end, nil)
        end
      end
      break
    end
  end
end
def.static("table", "table").OnHeroLevelUp = function(p, c)
  Cls._updateActivityInterface()
end
def.static("table", "table").OnActivityTodo = function(p, c)
  local actId = p[1] and p[1] or 0
  for act_id, openId in pairs(instance._featureList) do
    if actId == act_id then
      local actCfg = VoiceQuestionUtils.GetVoiceQuestionActCfgByActId(actId)
      local srcActId = actCfg.targetActId
      local bSrcActFinish, _ = Cls.IsActivityFinish(srcActId)
      if bSrcActFinish then
        if actCfg ~= nil then
          local bFinish, finishCount = Cls.IsActivityFinish(actId)
          Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
            actCfg.npcId
          })
        end
        break
      end
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {srcActId})
      break
    end
  end
end
def.static("table", "table").OnNPCService = function(p, c)
  local srvcId = p[1] and p[1] or 0
  local npcId = p[2] and p[2] or 0
  local actId = Cls.GetActivityIdBySrvcId(srvcId)
  if actId ~= 0 then
    local questionCfg = VoiceQuestionUtils.GetVoiceQuestionActCfgByActId(actId)
    local srcActId = questionCfg.targetActId
    local bSrcActFinish, _ = Cls.IsActivityFinish(srcActId)
    if bSrcActFinish then
      local voiceActFinish, finishCount = Cls.IsActivityFinish(actId)
      if finishCount >= questionCfg.maxTimes then
        Protocols.CSendGetLastVoiceQuestion(actId, npcId)
      else
        Protocols.CSendGetVoiceQuestionReq(actId, npcId)
      end
    else
      Toast(txtConst[3])
    end
  end
end
return VoiceQuestionModule.Commit()
