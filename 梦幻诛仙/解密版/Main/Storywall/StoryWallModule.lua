local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local StoryWallModule = Lplus.Extend(ModuleBase, "StoryWallModule")
local def = StoryWallModule.define
local instance
def.static("=>", StoryWallModule).Instance = function()
  if nil == instance then
    instance = StoryWallModule()
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, StoryWallModule.OnNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, StoryWallModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, StoryWallModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, StoryWallModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, StoryWallModule.OnFeatureOpenChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.storywall.SStoryWallInfoRes", StoryWallModule.OnSStoryWallInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.storywall.SStoryWallRefresh", StoryWallModule.OnSStoryWallRefresh)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.storywall.SReadStoryRes", StoryWallModule.OnSReadStoryRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.storywall.SReadStoryAwardRes", StoryWallModule.OnSReadStoryAwardRes)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
end
def.static("table", "table").OnNPCService = function(tbl, p2)
  local serviceId = tbl[1]
  if serviceId == constant.StoryWallConst.serviceid then
    require("Main.Storywall.ui.FoodShopPanel").Instance():ShowPanel()
  end
end
def.static("table", "table").OnActivityTodo = function(params, context)
  local actId = params[1]
  if actId == constant.StoryWallConst.activityid then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.StoryWallConst.npcid
    })
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
end
def.static("table", "table").OnFeatureOpenInit = function(tbl, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_STORYWALL)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if isOpen then
    activityInterface:removeCustomCloseActivity(constant.StoryWallConst.activityid)
  else
    activityInterface:addCustomCloseActivity(constant.StoryWallConst.activityid)
  end
  local npcId = constant.StoryWallConst.npcid
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {npcid = npcId, show = isOpen})
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if p.feature == Feature.TYPE_STORYWALL then
    if p.open then
      activityInterface:removeCustomCloseActivity(constant.StoryWallConst.activityid)
    else
      activityInterface:addCustomCloseActivity(constant.StoryWallConst.activityid)
    end
    local npcId = constant.StoryWallConst.npcid
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = npcId,
      show = p.open
    })
  end
end
def.static("table").OnSStoryWallInfoRes = function(p)
  Event.DispatchEvent(ModuleId.STORYWALL, gmodule.notifyId.Storywall.StoryWallInfo, {p})
end
def.static("table").OnSStoryWallRefresh = function(p)
  Event.DispatchEvent(ModuleId.STORYWALL, gmodule.notifyId.Storywall.StoryWallRefresh, {})
end
def.static("table").OnSReadStoryRes = function(p)
end
def.static("table").OnSReadStoryAwardRes = function(p)
  local str = textRes.activity[395]
  local awardInfo = require("Main.Award.AwardUtils").GetHtmlTextsFromAwardBean(p.targetAwardBean, str)
  for _, v in ipairs(awardInfo) do
    require("Main.Chat.PersonalHelper").SendOut(v)
  end
end
StoryWallModule.Commit()
return StoryWallModule
