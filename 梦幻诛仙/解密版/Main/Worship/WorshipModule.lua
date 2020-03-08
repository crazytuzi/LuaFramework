local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local WorshipModule = Lplus.Extend(ModuleBase, "WorshipModule")
local WorshipInterface = require("Main.Worship.WorshipInterface")
local worshipInterface = WorshipInterface.Instance()
local NPCInterface = require("Main.npc.NPCInterface")
local npcInterface = NPCInterface.Instance()
local def = WorshipModule.define
local instance
def.static("=>", WorshipModule).Instance = function()
  if not instance then
    instance = WorshipModule()
    instance.m_moduleId = ModuleId.WORSHIP
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worship.SSynWorshipInfo", WorshipModule.OnSSynWorshipInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worship.SSynFactionWorshipInfo", WorshipModule.OnSSynFactionWorshipInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worship.SSynRoleWorshipInfo", WorshipModule.OnSSynRoleWorshipInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worship.SWorshipNormalResult", WorshipModule.OnSWorshipNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worship.SWorshipSucBro", WorshipModule.OnSWorshipSucBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.worship.SWorshipSuc", WorshipModule.OnSWorshipSuc)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, WorshipModule.OnNpcNomalServer)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, WorshipModule.OnActivityToDo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, WorshipModule.OnActivityReset)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, WorshipModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, WorshipModule.OnGangChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, WorshipModule.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, WorshipModule.OnEnterWorld)
  npcInterface:RegisterNPCServiceCustomCondition(constant.CWorShipConst.serviceid, WorshipModule.OnNPCService_WorshipCondition)
end
def.override().OnReset = function(self)
  worshipInterface:Reset()
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  worshipInterface:setWorshipRedPoint()
end
def.static("table").OnSSynWorshipInfo = function(p)
  worshipInterface.worshipId2num = p.worshipId2num
  worshipInterface.myWorshipId = p.worshipId
  worshipInterface.lastCycleNum = p.lastCycleNum
  worshipInterface.curCycleNum = p.thisCycleNum
  worshipInterface.canGetSalary = p.canGetSalary
  worshipInterface.nextCanGetSalary = p.nextCanGetSalary
  worshipInterface.worshipRecord = p.worshipRecord
  worshipInterface:setWorshipRedPoint()
end
def.static("table").OnSSynFactionWorshipInfo = function(p)
  worshipInterface.worshipId2num = p.worshipId2num
  Event.DispatchEvent(ModuleId.WORSHIP, gmodule.notifyId.Worship.Worship_Info_Change, {})
end
def.static("table").OnSSynRoleWorshipInfo = function(p)
  worshipInterface.myWorshipId = p.worshipId
  worshipInterface.lastCycleNum = p.lastCycleNum
  worshipInterface.curCycleNum = p.thisCycleNum
  worshipInterface.canGetSalary = p.canGetSalary
  worshipInterface.nextCanGetSalary = p.nextCanGetSalary
  Event.DispatchEvent(ModuleId.WORSHIP, gmodule.notifyId.Worship.Worship_Info_Change, {})
end
def.static("table").OnSWorshipSucBro = function(p)
  local SingleWorshipInfo = require("netio.protocol.mzm.gsp.worship.SingleWorshipInfo").new(p.roleId, p.worshipId, p.contentIndex)
  worshipInterface:addWorshipRecord(SingleWorshipInfo)
  local worshipCfg = WorshipInterface.GetWorshipCfg(p.worshipId)
  if worshipCfg and worshipCfg.contentList[p.contentIndex] then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local GangData = require("Main.Gang.data.GangData").Instance()
    local GangInfo = GangData:GetGangBasicInfo()
    local roleName = "<font color=#00ff00>" .. p.roleName .. "</font>"
    local bangZhu = "<font color=#ffff00>" .. GangInfo.bangZhu .. "</font>"
    local str = string.format(worshipCfg.contentList[p.contentIndex], roleName, bangZhu)
    if p.goldNum > 0 then
      str = str .. string.format(textRes.Worship[2], p.goldNum)
    end
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  end
  Event.DispatchEvent(ModuleId.WORSHIP, gmodule.notifyId.Worship.Worship_Record_Change, {})
end
def.static("table").OnSWorshipSuc = function(p)
  worshipInterface.myWorshipId = p.worshipId
  worshipInterface:addWorshipNum(p.worshipId, 1)
  if p.goldNum > 0 then
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Worship[3], PersonalHelper.Type.Gold, p.goldNum)
  end
  worshipInterface:setWorshipRedPoint()
  Event.DispatchEvent(ModuleId.WORSHIP, gmodule.notifyId.Worship.Worship_Info_Change, {})
end
def.static("table").OnSWorshipNormalResult = function(p)
  local str = textRes.Worship.errorTips[p.result]
  if str then
    Toast(str)
  end
end
def.static("number", "=>", "boolean").OnNPCService_WorshipCondition = function(serviceId)
  if serviceId == constant.CWorShipConst.serviceid then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local activityInterface = ActivityInterface.Instance()
    if activityInterface:isAchieveActivityLevel(constant.CWorShipConst.activityId) and IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_WORSHIP_FACTION_MASTER) then
      return true
    else
      return false
    end
  end
  return true
end
def.static("table", "table").OnActivityToDo = function(p1, p2)
  warn("-------WorshipModule OnActivityToDo:", p1[1], constant.CWorShipConst.activityId)
  if p1[1] == constant.CWorShipConst.activityId then
    local GangModule = require("Main.Gang.GangModule")
    local bHasGang = GangModule.Instance():HasGang()
    if bHasGang then
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
        constant.CWorShipConst.npcId
      })
    else
      Toast(textRes.Worship[1])
    end
  end
end
def.static("table", "table").OnActivityReset = function(p1, p2)
  if p1[1] == constant.CWorShipConst.activityId then
    worshipInterface.myWorshipId = 0
    worshipInterface.lastCycleNum = worshipInterface.curCycleNum
    worshipInterface.canGetSalary = worshipInterface.nextCanGetSalary
    worshipInterface.curCycleNum = 0
    worshipInterface.nextCanGetSalary = 0
    worshipInterface.worshipRecord = {}
    worshipInterface:setWorshipRedPoint()
  end
end
def.static("table", "table").OnNpcNomalServer = function(p1, p2)
  if p1[1] == constant.CWorShipConst.serviceid and p1[2] == constant.CWorShipConst.npcId then
    local GangModule = require("Main.Gang.GangModule")
    local bHasGang = GangModule.Instance():HasGang()
    if bHasGang then
      require("Main.Worship.ui.WorshipPanel").Instance():ShowPanel()
    else
      Toast(textRes.Worship[1])
    end
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_WORSHIP_FACTION_MASTER then
    worshipInterface:setWorshipRedPoint()
  end
end
def.static("table", "table").OnGangChange = function(p1, p2)
  worshipInterface:setWorshipRedPoint()
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  worshipInterface:setWorshipRedPoint()
end
return WorshipModule.Commit()
