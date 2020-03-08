local FILE_NAME = (...)
local Lplus = require("Lplus")
local PetsArenaMgr = Lplus.Class(FILE_NAME)
local def = PetsArenaMgr.define
local Cls = PetsArenaMgr
local instance
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local const = constant.CPetArenaConst
local txtConst = textRes.Pet.PetsArena
local ChatModule = Lplus.ForwardDeclare("ChatModule")
def.const("number").MAX_MODEL = 9
def.const("number").MAX_TEAM = 4
def.field("number")._state = 0
def.field("userdata")._recordid = nil
def.field("table")._awardInfo = nil
def.const("table").STATUS = {NONE = 0, WATCH_VIDEO = 1}
def.static("=>", PetsArenaMgr).Instance = function()
  if instance == nil then
    instance = PetsArenaMgr()
  end
  return instance
end
def.method().Init = function(self)
  require("Main.Pet.PetsArena.PetsArenaProtocols").Instance():Init()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, Cls.OnActivityTodo)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, Cls.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, Cls.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_PET_BATTLE, Cls.OnLeavePetFight)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.WATCH_PET_FIGHT_VIDEO_OK, Cls.OnWatchVideoOK)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_FIGHT_RECORD_OK, Cls.OnGetFightRecordOK)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.START_PETS_FIGHT_SUCCESS, Cls.OnStartPetFightOK)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.REPORT_FIGHT_END_OK, Cls.OnReportFightEndSuccess)
end
def.static("=>", "table").GetProtocol = function()
  return require("Main.Pet.PetsArena.PetsArenaProtocols")
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local bFeatureOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_PET_ARENA)
  return bFeatureOpen
end
def.static("=>", "boolean").IsRanklistOpen = function(self)
  local bFeatureOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_PET_ARENA_CHART)
  return bFeatureOpen
end
def.static("boolean").updateActivtityInterface = function(bOpen)
  local activityInterface = ActivityInterface.Instance()
  local actId = const.ACTIVITY_CFG_ID
  if bOpen then
    activityInterface:removeCustomCloseActivity(actId)
  else
    activityInterface:addCustomCloseActivity(actId)
  end
end
def.static("=>", "boolean").IsWatchingVideo = function()
  return instance._state == Cls.STATUS.WATCH_VIDEO
end
def.static("table").showAward = function(p)
  local count = p.add_point
  if count < 1 then
    return
  end
  local strTable = {}
  local spriteName = "Icon_ChongWuJingJiChang"
  local colorCfg = GetNameColorCfg(701300020)
  local color = string.format("#%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
  table.insert(strTable, string.format("%s&nbsp;<img src='%s:%s' width=22 height=22>&nbsp;", txtConst[33], RESPATH.COMMONATLAS, spriteName))
  table.insert(strTable, string.format("<font color=%s> %s</font>", color, count))
  local content = table.concat(strTable)
  Toast(content)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.PERSONAL, HtmlHelper.Style.Personal, {content = content})
end
def.static("table", "table").OnActivityTodo = function(p, c)
  local actId = p[1] or 0
  warn("actId", actId, "pet arena activity id", const.ACTIVITY_CFG_ID)
  if actId == const.ACTIVITY_CFG_ID then
    if _G.CheckCrossServerAndToast() then
      return
    end
    local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
    if role:IsInState(RoleState.GANGBATTLE) then
      Toast(txtConst[38])
      return
    end
    if _G.GetHeroProp().level < const.OPEN_LEVEL then
      Toast(txtConst[3]:format(const.OPEN_LEVEL))
      return
    end
    require("Main.Pet.PetsArena.ui.UIPetsArenaMain").Instance():ShowPanel()
  end
end
def.static("table", "table").OnFeatureInit = function(p, c)
  local bOpen = Cls.IsFeatureOpen()
  Cls.updateActivtityInterface(bOpen)
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  local feature = p.feature
  if feature == Feature.TYPE_PET_ARENA then
    local bOpen = Cls.IsFeatureOpen()
    Cls.updateActivtityInterface(bOpen)
  end
end
def.static("table", "table").OnLeavePetFight = function(p, c)
  if instance._state == Cls.STATUS.WATCH_VIDEO then
    require("Main.Pet.PetsArena.ui.UIEndFightOption").Instance():ShowPanel(instance._recordid)
    instance._recordid = nil
    instance._state = Cls.STATUS.NONE
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.WATCH_VIDEO_END, nil)
  else
    Cls.GetProtocol().CReportFightEnd()
  end
end
def.static("table", "table").OnWatchVideoOK = function(p, c)
  instance._recordid = p.recordid
  instance._state = Cls.STATUS.WATCH_VIDEO
end
def.static("table", "table").OnGetFightRecordOK = function(p, c)
  require("Main.Pet.PetsArena.ui.UIPetsArenaBattleLog").Instance():ShowPanel(p.records)
end
def.static("table", "table").OnStartPetFightOK = function(p, c)
  instance._awardInfo = p.award_info
  instance._awardInfo.addPt = p.add_point
end
def.static("table", "table").OnReportFightEndSuccess = function(p, c)
  Cls.showAward(p)
end
return PetsArenaMgr.Commit()
