local Lplus = require("Lplus")
local ActivityInterface = require("Main.activity.ActivityInterface")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local MemoryCompetitionUtils = require("Main.activity.MemoryCompetition.MemoryCompetitionUtils")
local NPCInterface = require("Main.npc.NPCInterface")
local MemoryCompetitionMgr = Lplus.Class("MemoryCompetitionMgr")
local def = MemoryCompetitionMgr.define
local instance
def.static("=>", MemoryCompetitionMgr).Instance = function()
  if nil == instance then
    instance = MemoryCompetitionMgr()
  end
  return instance
end
def.method().Init = function(self)
  require("Main.activity.MemoryCompetition.RomanticDance.RomanticDanceMgr").Instance():Init()
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, MemoryCompetitionMgr.OnNpcService)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, MemoryCompetitionMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MemoryCompetitionMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MemoryCompetitionMgr.OnFeatureOpenChange)
  self:RegisterActivityNpcService()
end
def.static("table", "table").OnNpcService = function(p1, p2)
  local serviceId = p1[1]
  local npcId = p1[2]
  local activityId = MemoryCompetitionUtils.GetActivityIdByNpcIdAndServiceId(npcId, serviceId)
  if activityId ~= 0 then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Memory_Competition_Enter, {activityId})
  end
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  local activityInfo = MemoryCompetitionUtils.GetMemoryCompetionByActivityId(activityId)
  if activityInfo ~= nil then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      activityInfo.npcId
    })
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local self = MemoryCompetitionMgr.Instance()
  self:UpdateActivityIDIPState()
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
  local featureType = p1.feature
  if featureType == Feature.TYPE_MEMORY_COMPETITION or MemoryCompetitionUtils.IsMemoryCompetitionIDIP(featureType) then
    local self = MemoryCompetitionMgr.Instance()
    self:UpdateActivityIDIPState()
  end
end
def.method().UpdateActivityIDIPState = function(self)
  local activityIDIPCfg = MemoryCompetitionUtils.GetMemoryCompetitionActivityIdAndIDIP()
  for idx, cfg in pairs(activityIDIPCfg) do
    if _G.IsFeatureOpen(Feature.TYPE_MEMORY_COMPETITION) then
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
  local allActivity = MemoryCompetitionUtils.GetAllActivity()
  for idx, activityCfg in pairs(allActivity) do
    npcInterface:RegisterNPCServiceCustomCondition(activityCfg.npcServiceId, MemoryCompetitionMgr.OnNpcServiceCheck)
  end
end
def.static("number", "=>", "boolean").OnNpcServiceCheck = function(serviceId)
  local featureId = MemoryCompetitionUtils.GetIDIPByNpcServiceId(serviceId)
  if featureId == 0 then
    return
  end
  return _G.IsFeatureOpen(Feature.TYPE_MEMORY_COMPETITION) and _G.IsFeatureOpen(featureId)
end
MemoryCompetitionMgr.Commit()
return MemoryCompetitionMgr
