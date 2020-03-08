local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GangRaceModule = Lplus.Extend(ModuleBase, "GangRaceModule")
require("Main.module.ModuleId")
local GangRacePanel = require("Main.GangRace.ui.GangRacePanel")
local GangRaceProtocol = require("Main.GangRace.GangRaceProtocol")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local def = GangRaceModule.define
local instance
def.field(GangRacePanel)._dlg = nil
def.field("number")._npcId = 0
def.static("=>", GangRaceModule).Instance = function()
  if nil == instance then
    instance = GangRaceModule()
    instance._dlg = GangRacePanel.Instance()
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, GangRaceModule.OnNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, GangRaceModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, GangRaceModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, GangRaceModule.OnitemMoneyGoldChanged)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, GangRaceModule.OnChatBtnClick)
  Event.RegisterEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_GangActOpen, GangRaceModule.OnGangActOpen)
  GangRaceProtocol.Init()
  ModuleBase.Init(self)
  self._dlg:Init()
end
def.override().OnReset = function(self)
  if self._dlg then
    self._dlg.bWaitData = false
  end
end
def.static("table", "table").onShow = function(p1, p2)
  instance:ShowMainPanel()
end
def.method("=>", "number").GetNpcId = function(self)
  return self._npcId
end
def.static("table", "table").OnNPCService = function(tbl, p2)
  local serviceId = tbl[1]
  if NPCServiceConst.GangRace_Enter == serviceId then
    instance._npcId = tbl[2]
    instance:ShowMainPanel()
  end
end
def.static("table", "table").OnActivityTodo = function(params, context)
  if params[1] == constant.CGangRaceConsts.activity then
    instance:GoToActivityNPC()
  end
end
def.static("table", "table").OnitemMoneyGoldChanged = function(p1, p2)
  if instance._dlg then
    instance._dlg:UpdateGoldMoney()
  end
end
def.static("table", "table").OnChatBtnClick = function(params, tbl)
  local id = params.id
  if string.sub(id, 1, #"gangracenpc") == "gangracenpc" then
    if not PlayerIsTransportable() then
      Toast(textRes.GangRace[11])
      return
    end
    instance:GoToActivityNPC()
  end
end
def.static("table", "table").OnGangActOpen = function(params, tbl)
  instance:ShowMainPanel()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  if instance._dlg.m_panel ~= nil then
    instance._dlg:DestroyPanel()
  end
end
def.method().GoToActivityNPC = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local actitivityInPeriod = ActivityInterface.Instance()._activityInPeriod
  if actitivityInPeriod[constant.CGangRaceConsts.activity] ~= nil then
    local npcid = constant.CGangRaceConsts.npcid
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcid})
  else
    Toast(textRes.activity[51])
  end
end
def.method().ShowMainPanel = function(self)
  instance._dlg:ShowPanel()
end
GangRaceModule.Commit()
return GangRaceModule
