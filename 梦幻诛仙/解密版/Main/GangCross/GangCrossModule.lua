local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GangCrossModule = Lplus.Extend(ModuleBase, "GangCrossModule")
local GangCrossData = require("Main.GangCross.data.GangCrossData")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local GangCrossProtocol = require("Main.GangCross.GangCrossProtocol")
local GangCrossBattleMgr = require("Main.GangCross.GangCrossBattleMgr")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local def = GangCrossModule.define
local instance
def.field("number").activeTimer = 0
def.static("=>", GangCrossModule).Instance = function()
  if nil == instance then
    instance = GangCrossModule()
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, GangCrossModule.OnNPCService)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, GangCrossModule.OnChatBtnClick)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, GangCrossModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, GangCrossModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD_STAGE, GangCrossModule.OnLeaveWorldStage)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, GangCrossModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, GangCrossModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, GangCrossModule.OnGangInfoChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, GangCrossModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GangCrossModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_GangActOpen, GangCrossModule.OnGangActOpen)
  Event.RegisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_SignedUpFactionList, GangCrossModule.OnSignedUpFactionList)
  Event.RegisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_AgainstList, GangCrossModule.OnAgainstList)
  GangCrossProtocol.Init()
  GangCrossBattleMgr.Instance():Init()
  ModuleBase.Init(self)
end
def.override().LateInit = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.ACTIVITY):RegisterActivityTipFunc(constant.GangCrossConsts.Activityid, require("Main.GangCross.GangCrossBattleMgr").CheckValid)
end
def.override().OnReset = function(self)
  GangCrossData.Instance():OnReset()
  if self.activeTimer > 0 then
    GameUtil.RemoveGlobalTimer(self.activeTimer)
    self.activeTimer = 0
  end
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(Feature.TYPE_CROSS_COMPETE)
  return isOpen
end
def.method().SetTimer = function(self)
  if self.activeTimer > 0 then
    return
  end
  local function OnActivityBegin()
    local ActivityInterface = require("Main.activity.ActivityInterface")
    ActivityInterface.Instance():displayActivityTip(constant.GangCrossConsts.Activityid, true)
    local display = textRes.GangCross[34] or ""
    local button = string.format("<a href='btn_gangcrossopen' id=btn_gangcrossopen><font color=#%s><u>[%s]</u></font></a>", link_defalut_color, textRes.GangCross[35])
    local str = string.format("%s%s", display, button)
    GangCrossModule.ShowInGangChannel(str)
    if GangCrossData.Instance():IsMatchState() then
      local gangUtility = require("Main.Gang.GangUtility").Instance()
      gangUtility:AddGangActivityRedPoint(constant.GangCrossConsts.Activityid)
    end
  end
  local showTip = require("Main.GangCross.GangCrossBattleMgr").CheckValid()
  local minutes = constant.GangCrossConsts.PrepareMinutes + constant.GangCrossConsts.FightMinutes + constant.GangCrossConsts.WaitForceEndMinutes + constant.GangCrossConsts.RestMinutes
  local timeDiff = constant.GangCrossConsts.SignUpDays * 86400 + (constant.GangCrossConsts.MatchHours + constant.GangCrossConsts.MailRemindHours) * 3600 + constant.GangCrossConsts.WaitMinutes * 60
  self.activeTimer = GameUtil.AddGlobalTimer(2, false, function()
    if showTip then
      showTip = false
    else
      local actTime = GangCrossUtility.Instance():getActivityWeekBeginTime()
      if actTime > 0 and gmodule.moduleMgr:GetModule(ModuleId.GANG_CROSS):IsFeatureOpen() then
        local actIndex = GangCrossData.Instance():GetCompeteIndex()
        if actIndex >= constant.GangCrossConsts.MaxCompeteCountOfOneTime then
          actIndex = 1
        else
          actIndex = 0
        end
        actTime = actTime + timeDiff + actIndex * minutes * 60
        local value = GetServerTime() - actTime
        if value >= 0 and value < 4 then
          OnActivityBegin()
          showTip = true
        end
      end
    end
  end)
end
def.static("string").ShowInGangChannel = function(display)
  local gangId = require("Main.Gang.data.GangData").Instance():GetGangId()
  if gangId then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(display, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  end
end
def.static("table", "table").OnChatBtnClick = function(params, tbl)
  local id = params.id
  if string.sub(id, 1, #"gangcrossopen") == "gangcrossopen" then
    GangCrossModule.OnActivityTodo({
      constant.GangCrossConsts.Activityid
    }, nil)
  end
end
def.static("table", "table").OnLeaveWorld = function(params)
  if instance then
    instance:OnReset()
  end
end
def.static("table", "table").OnEnterWorld = function(params)
  if not _G.IsCrossingServer() then
    require("Main.GangCross.ui.ResultPanel").Instance():HidePanel()
    require("Main.GangCross.ui.SingleResultPanel").Instance():HidePanel()
    require("Main.GangCross.ui.GangCrossReturnPanel").Instance():HidePanel()
  end
  instance:SetTimer()
  local ActivityInterface = require("Main.activity.ActivityInterface")
  if not ActivityInterface.Instance():isActivityOpend(constant.GangCrossConsts.Activityid) and ActivityInterface.Instance():isActivityOpend2(constant.GangCrossConsts.Activityid) then
    ActivityInterface.Instance():displayActivityTip(constant.GangCrossConsts.Activityid, true)
  end
end
def.static("table", "table").OnLeaveWorldStage = function(p1, p2)
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if _G.IsCrossingServer() then
    require("Main.GangCross.ui.GangCrossLoadingPanel").Instance():HidePanel()
  end
end
def.static("table", "table").OnGangInfoChange = function(params, context)
  local hasGang = require("Main.Gang.GangModule").Instance():HasGang()
  if not hasGang then
    GangCrossData.Instance():SetCompeteIndex(0)
    GangCrossData.Instance():setCrossGangBattleState(false)
  end
end
def.static("table", "table").OnNPCService = function(params, context)
end
def.static("table", "table").OnActivityTodo = function(params, context)
  local activityId = params[1]
  if activityId == constant.GangCrossConsts.Activityid then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    if ActivityInterface.Instance():isActivityOpend2(activityId) then
      Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_GangActOpen, nil)
    else
      Toast(textRes.activity[51])
    end
  end
end
def.static("table", "table").OnGangActOpen = function(params, context)
  local isOpen = gmodule.moduleMgr:GetModule(ModuleId.GANG_CROSS):IsFeatureOpen()
  if not isOpen then
    Toast(textRes.GangCross[27])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crosscompete.CFactionListReq").new())
end
def.static("table", "table").OnSignedUpFactionList = function(params, context)
  local gangList = params[1]
  require("Main.GangCross.ui.EnterListPanel").Instance():ShowPanel(gangList)
end
def.static("table", "table").OnAgainstList = function(params, context)
  local gangList = params[1]
  require("Main.GangCross.ui.VersusListPanel").Instance():ShowPanel(gangList)
end
def.static("table", "table").OnFeatureOpenInit = function(tbl, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_CROSS_COMPETE)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if isOpen then
    activityInterface:removeCustomCloseActivity(constant.GangCrossConsts.Activityid)
  else
    activityInterface:addCustomCloseActivity(constant.GangCrossConsts.Activityid)
  end
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if p.feature == Feature.TYPE_CROSS_COMPETE then
    if p.open then
      activityInterface:removeCustomCloseActivity(constant.GangCrossConsts.Activityid)
    else
      activityInterface:addCustomCloseActivity(constant.GangCrossConsts.Activityid)
    end
  end
end
GangCrossModule.Commit()
return GangCrossModule
