local Lplus = require("Lplus")
local WantedMgr = Lplus.Class("WantedMgr")
local def = WantedMgr.define
local instance
local AnnouncementTip = require("GUI.AnnouncementTip")
local ChatModule = require("Main.Chat.ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
def.static("=>", WantedMgr).Instance = function()
  if instance == nil then
    instance = WantedMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SNotifyWanted", WantedMgr.OnSNotifyWanted)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SWantedListRsp", WantedMgr.OnSWantedListRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SWantedRoleError", WantedMgr.OnSWantedRoleError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SNotifyPVPFightTip", WantedMgr.OnSNotifyPVPFightTip)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SNotifyPVEFightTip", WantedMgr.OnSNotifyPVEFightTip)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SNotifyPVPFightResult", WantedMgr.OnSNotifyPVPFightResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SNotifyPVEFightResult", WantedMgr.OnSNotifyPVEFightResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SNotifyNPCStartWanted", WantedMgr.OnSNotifyNPCStartWanted)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SNotifyAwardCountMax", WantedMgr.OnSNotifyAwardCountMax)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SQueryWantedRoleStatusRsp", WantedMgr.OnSQueryWantedStateRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wanted.SQueryWantedRoleStatusError", WantedMgr.OnSQueryWantedStateFailed)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, WantedMgr.OnNpcService)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, WantedMgr.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, WantedMgr.OnFeatureOpenChange)
end
def.static("table").OnSNotifyWanted = function(p)
  local playerName = _G.GetStringFromOcts(p.name)
  local annouceStr = string.format(textRes.PlayerPK.PlayerWanted[11], playerName, constant.CPKConsts.WANTED_MORAL_VALUE)
  local sysStr = string.format(textRes.PlayerPK.PlayerWanted[12], playerName, constant.CPKConsts.WANTED_MORAL_VALUE)
  AnnouncementTip.Announce(annouceStr)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = sysStr})
end
def.static("table").OnSWantedListRsp = function(p)
  local WantedPlayer = require("Main.PlayerPK.Wanted.data.WantedPlayer")
  local players = {}
  for i = 1, #p.wantedList do
    local player = WantedPlayer()
    player:RawSet(p.wantedList[i])
    table.insert(players, player)
  end
  local params = {}
  params.players = players
  params.totalPage = p.pageTotal
  params.curPage = p.pageNo
  Event.DispatchEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.PlayerWanted.Receive_Wanted_Data, params)
end
def.static("table").OnSWantedRoleError = function(p)
  local SWantedRoleError = require("netio.protocol.mzm.gsp.wanted.SWantedRoleError")
  local roleName = _G.GetStringFromOcts(p.roleName)
  local players = {}
  for i = 1, #(p.params or {}) do
    table.insert(players, _G.GetStringFromOcts(p.params[i]))
  end
  if p.errorCode == SWantedRoleError.ROLE_IN_MAP then
    Toast(string.format(textRes.PlayerPK.PlayerWanted.SWantedRoleError[1], roleName))
  elseif p.errorCode == SWantedRoleError.ROLE_IN_FIGHT then
    Toast(string.format(textRes.PlayerPK.PlayerWanted.SWantedRoleError[2], roleName))
  elseif p.errorCode == SWantedRoleError.MONEY_NOT_ENOUGH then
    local CurrencyFactory = require("Main.Currency.CurrencyFactory")
    local moneyData = CurrencyFactory.Create(constant.CPKConsts.ARREST_MONEY_TYPE)
    Toast(string.format(textRes.PlayerPK.PlayerWanted.SWantedRoleError[3], table.concat(players, "\227\128\129"), moneyData:GetName()))
  elseif p.errorCode == SWantedRoleError.WANTED_COUNT_MAX then
    Toast(string.format(textRes.PlayerPK.PlayerWanted.SWantedRoleError[4], table.concat(players, "\227\128\129"), roleName))
  elseif p.errorCode == SWantedRoleError.ROLE_OFFLINE then
    Toast(string.format(textRes.PlayerPK.PlayerWanted.SWantedRoleError[5], roleName))
  elseif p.errorCode == SWantedRoleError.ROLE_CAN_NOT_BE_WANTED then
    Toast(string.format(textRes.PlayerPK.PlayerWanted.SWantedRoleError[6], roleName))
  elseif p.errorCode == SWantedRoleError.ROLE_IS_HONGMING then
    Toast(string.format(textRes.PlayerPK.PlayerWanted.SWantedRoleError[7], table.concat(players, "\227\128\129")))
  elseif p.errorCode == SWantedRoleError.ROLE_LEVEL_LOW then
    Toast(string.format(textRes.PlayerPK.PlayerWanted.SWantedRoleError[8], table.concat(players, "\227\128\129")))
  elseif p.errorCode == SWantedRoleError.ROLE_STATUS_CAN_NOT_BE_WANTED then
    Toast(string.format(textRes.PlayerPK.PlayerWanted.SWantedRoleError[9], table.concat(players, "\227\128\129")))
  else
    Toast(string.format(textRes.PlayerPK.PlayerWanted.SWantedRoleError[-1], p.errorCode))
  end
end
def.static("table").OnSNotifyPVPFightTip = function(p)
  local activeList = {}
  for i = 1, #p.activeNameList do
    table.insert(activeList, _G.GetStringFromOcts(p.activeNameList[i]))
  end
  local passiveList = {}
  for i = 1, #p.passiveNameList do
    table.insert(passiveList, _G.GetStringFromOcts(p.passiveNameList[i]))
  end
  Toast(string.format(textRes.PlayerPK.PlayerWanted[20], table.concat(activeList, "\227\128\129"), table.concat(passiveList, "\227\128\129")))
end
def.static("table").OnSNotifyPVEFightTip = function(p)
  local teamData = require("Main.Team.TeamData").Instance()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  if teamData:HasTeam() then
    local passiveList = {}
    for i = 1, #p.wantedIdSet do
      local member = teamData:getMember(p.wantedIdSet[i])
      if member ~= nil then
        table.insert(passiveList, member.name)
      end
    end
    if p.fightCount == 1 then
      Toast(string.format(textRes.PlayerPK.PlayerWanted[17], table.concat(passiveList, "\227\128\129")))
    else
      Toast(string.format(textRes.PlayerPK.PlayerWanted[18], table.concat(passiveList, "\227\128\129")))
    end
  else
    Toast(textRes.PlayerPK.PlayerWanted[15])
  end
end
def.static("table").OnSNotifyPVEFightResult = function(p)
  local SNotifyPVEFightResult = require("netio.protocol.mzm.gsp.wanted.SNotifyPVEFightResult")
  local passiveList = {}
  for i = 1, #p.passiveNameList do
    table.insert(passiveList, _G.GetStringFromOcts(p.passiveNameList[i]))
  end
  local str
  if p.result == SNotifyPVEFightResult.SUCCESS then
    if p.fightCount == 1 then
      str = string.format(textRes.PlayerPK.PlayerWanted[23], table.concat(passiveList, "\227\128\129"))
    else
      str = string.format(textRes.PlayerPK.PlayerWanted[25], table.concat(passiveList, "\227\128\129"))
    end
  elseif p.fightCount == 1 then
    str = string.format(textRes.PlayerPK.PlayerWanted[24], table.concat(passiveList, "\227\128\129"))
  else
    str = string.format(textRes.PlayerPK.PlayerWanted[30], table.concat(passiveList, "\227\128\129"))
  end
  if str ~= nil then
    AnnouncementTip.Announce(str)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  end
end
def.static("table").OnSNotifyPVPFightResult = function(p)
  local SNotifyPVPFightResult = require("netio.protocol.mzm.gsp.wanted.SNotifyPVPFightResult")
  local activeList = {}
  for i = 1, #p.activeNameList do
    table.insert(activeList, _G.GetStringFromOcts(p.activeNameList[i]))
  end
  local passiveList = {}
  for i = 1, #p.passiveNameList do
    table.insert(passiveList, _G.GetStringFromOcts(p.passiveNameList[i]))
  end
  local str
  if p.result == SNotifyPVPFightResult.SUCCESS then
    str = string.format(textRes.PlayerPK.PlayerWanted[21], table.concat(passiveList, "\227\128\129"), table.concat(activeList, "\227\128\129"), table.concat(activeList, "\227\128\129"))
  else
    str = string.format(textRes.PlayerPK.PlayerWanted[22], table.concat(activeList, "\227\128\129"), table.concat(passiveList, "\227\128\129"))
  end
  if str ~= nil then
    AnnouncementTip.Announce(str)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  end
end
def.static("table").OnSNotifyNPCStartWanted = function(p)
  local roleName = _G.GetStringFromOcts(p.roleName)
  local str = string.format(textRes.PlayerPK.PlayerWanted[26], roleName)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnSNotifyAwardCountMax = function(p)
  local str = string.format(textRes.PlayerPK.PlayerWanted[31], constant.CPKConsts.WANTED_AWARD_MAX_COUNT_PER_DAY)
  Toast(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.PERSONAL, HtmlHelper.Style.Personal, {content = str})
end
def.static("table", "table").OnNpcService = function(p1, p2)
  local serviceId = p1[1]
  local npcId = p1[2]
  if npcId == constant.CPKConsts.WANTED_NPC_ID and serviceId == constant.CPKConsts.ARREST_SERVICE_ID then
    WantedMgr.Instance():CheckToShowPlayerWantedPanel()
  end
end
def.static("table", "table").OnFeatureInit = function(p, c)
  local isOpen = WantedMgr.IsFeatureOpen()
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
    npcid = constant.CPKConsts.WANTED_NPC_ID,
    show = isOpen
  })
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  local isOpen = WantedMgr.IsFeatureOpen()
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
    npcid = constant.CPKConsts.WANTED_NPC_ID,
    show = isOpen
  })
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_WANTED)
  return isOpen
end
def.static("=>", "boolean").CheckIsFeatureOpenAndToast = function()
  local isOpen = WantedMgr.IsFeatureOpen()
  if not isOpen then
    Toast(textRes.PlayerPK.PlayerWanted[5])
    return false
  end
  return true
end
def.method().CheckToShowPlayerWantedPanel = function(self)
  if not WantedMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local PlayerWantedPanel = require("Main.PlayerPk.Wanted.ui.PlayerWantedPanel")
  PlayerWantedPanel.Instance():ShowPanel()
end
def.method().GoToPlayerWantedNpc = function(self)
  if not WantedMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.CPKConsts.WANTED_NPC_ID
  })
end
def.method("number").QueryPlayerWantedData = function(self, page)
  if not WantedMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.wanted.CWantedListReq").new(page)
  gmodule.network.sendProtocol(req)
end
def.method("table").FightWithWantedPlayer = function(self, player)
  if not WantedMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local isSelfRedState = self:IsSelefRedState()
  if isSelfRedState then
    Toast(textRes.PlayerPK.PlayerWanted[13])
    return
  end
  if player:IsOutOfTime() then
    Toast(textRes.PlayerPK.PlayerWanted[14])
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local minLevel = player:GetLevel() - constant.CPKConsts.ARREST_LEVEL_DIFF
  if teamData:HasTeam() then
    local members = teamData:GetAllTeamMembers()
    for i = 1, #members do
      if minLevel > members[i].level then
        Toast(string.format(textRes.PlayerPK.PlayerWanted[8], members[i].name, player:GetName(), constant.CPKConsts.ARREST_LEVEL_DIFF))
        return
      end
    end
  elseif minLevel > heroProp.level then
    Toast(string.format(textRes.PlayerPK.PlayerWanted[7], player:GetName(), constant.CPKConsts.ARREST_LEVEL_DIFF))
    return
  end
  local needMoney = constant.CPKConsts.ARREST_PRICE
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local moneyData = CurrencyFactory.Create(constant.CPKConsts.ARREST_MONEY_TYPE)
  local function attendFight()
    if Int64.lt(moneyData:GetHaveNum(), needMoney) then
      moneyData:AcquireWithQuery()
      return
    end
    local req = require("netio.protocol.mzm.gsp.wanted.CWantedRoleReq").new(player:GetPlayerId())
    gmodule.network.sendProtocol(req)
  end
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.PlayerPK.PlayerWanted[9], string.format(textRes.PlayerPK.PlayerWanted[10], needMoney, moneyData:GetName()), function(result)
    if result == 1 then
      attendFight()
    end
  end, nil)
end
def.method("=>", "boolean").IsSelefRedState = function(self)
  local PKMgr = require("Main.PlayerPK.PKMgr")
  return PKMgr.IsBeWanted()
end
def.static("userdata").QueryPlayerWantedState = function(roleId)
  if not WantedMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.wanted.CQueryWantedRoleStatusReq").new(roleId)
  gmodule.network.sendProtocol(req)
end
def.static("table").OnSQueryWantedStateRes = function(p)
  Event.DispatchEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.PlayerWanted.RcvWantedStateData, p)
end
def.static("table").OnSQueryWantedStateFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.wanted.SQueryWantedRoleStatusError")
  local txtConst = textRes.PlayerPK.PlayerWanted.SWantedRoleError
  if p.errorCode == ERROR_CODE.ROLE_OFFLINE then
    Toast(txtConst[10])
  elseif p.errorCode == ERROR_CODE.ROLE_CAN_NOT_BE_WANTED then
    Toast(txtConst[11])
  end
end
return WantedMgr.Commit()
