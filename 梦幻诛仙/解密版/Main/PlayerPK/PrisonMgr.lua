local Lplus = require("Lplus")
local PrisonMgr = Lplus.Class("PrisonMgr")
local def = PrisonMgr.define
local instance
local AnnouncementTip = require("GUI.AnnouncementTip")
local ChatModule = require("Main.Chat.ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local NPCInterface = require("Main.npc.NPCInterface")
def.static("=>", PrisonMgr).Instance = function()
  if instance == nil then
    instance = PrisonMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.prison.SGetInJailLeftTimeRsp", PrisonMgr.OnSGetInJailLeftTimeRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.prison.SJailBreakError", PrisonMgr.OnSJailBreakError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.prison.SNotifyJailBreakResult", PrisonMgr.OnSNotifyJailBreakResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.prison.SPrisonListRsp", PrisonMgr.OnSPrisonListRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.prison.SJailDeliveryError", PrisonMgr.OnSJailDeliveryError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.prison.SNotifyJailDeliveryBegin", PrisonMgr.OnSNotifyJailDeliveryBegin)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.prison.SNotifyJailDeliveryResult", PrisonMgr.OnSNotifyJailDeliveryResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.prison.SNotifyPutInJail", PrisonMgr.OnSNotifyPutInJail)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, PrisonMgr.OnNpcService)
  local npcInterface = NPCInterface.Instance()
  npcInterface:RegisterNPCServiceCustomCondition(constant.CPKConsts.VISIT_PRISON_SERVICE_ID, PrisonMgr.OnNPCService_VisitPrison)
end
def.static("table").OnSGetInJailLeftTimeRsp = function(p)
  local endTimeStamp = Int64.ToNumber(p.endTimeStamp / 1000)
  local curTime = _G.GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local endTime = AbsoluteTimer.GetServerTimeTable(endTimeStamp)
  local leftTime = endTimeStamp - curTime
  local leftTimeTbl = _G.Seconds2HMSTime(leftTime)
  local str = string.format(textRes.PlayerPK.PlayerPrison[1], leftTimeTbl.h, leftTimeTbl.m, leftTimeTbl.s, endTime.year, endTime.month, endTime.day, endTime.hour, endTime.min, endTime.sec)
  local contents = {}
  local content = {}
  content.npcid = constant.CPKConsts.PRISON_BREAK_NPC_ID
  content.txt = str
  table.insert(contents, content)
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  taskModule:ShowTaskTalkCustom(contents, nil, nil)
end
def.static("table").OnSJailBreakError = function(p)
  local JailAction = require("netio.protocol.mzm.gsp.prison.JailAction")
  local players = {}
  for i = 1, #(p.params or {}) do
    table.insert(players, _G.GetStringFromOcts(p.params[i]))
  end
  if p.errorCode == JailAction.JAIL_DELIVERY then
    Toast(string.format(textRes.PlayerPK.PlayerPrison.SJailBreakError[3], table.concat(players, "\227\128\129")))
  elseif p.errorCode == JailAction.MONEY_NOT_ENOUGH then
    local needMoney = constant.CPKConsts.PRISON_BREAK_PRICE
    local CurrencyFactory = require("Main.Currency.CurrencyFactory")
    local moneyData = CurrencyFactory.Create(constant.CPKConsts.PRISON_BREAK_MONEY_TYPE)
    Toast(string.format(textRes.PlayerPK.PlayerPrison.SJailBreakError[6], table.concat(players, "\227\128\129"), moneyData:GetName()))
  else
    Toast(string.format(textRes.PlayerPK.PlayerPrison.SJailBreakError[-1], p.errorCode))
  end
end
def.static("table").OnSNotifyJailBreakResult = function(p)
  local players = {}
  for i = 1, #(p.nameList or {}) do
    table.insert(players, _G.GetStringFromOcts(p.nameList[i]))
  end
  local str
  local SNotifyJailBreakResult = require("netio.protocol.mzm.gsp.prison.SNotifyJailBreakResult")
  if p.result == SNotifyJailBreakResult.SUCCESS then
    str = string.format(textRes.PlayerPK.PlayerPrison[6], table.concat(players, "\227\128\129"))
  else
    str = string.format(textRes.PlayerPK.PlayerPrison[7], table.concat(players, "\227\128\129"))
  end
  if str ~= nil then
    AnnouncementTip.Announce(str)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  end
end
def.static("table").OnSPrisonListRsp = function(p)
  local PrisonPlayer = require("Main.PlayerPK.Prison.data.PrisonPlayer")
  local players = {}
  for i = 1, #p.prisonList do
    local player = PrisonPlayer()
    player:RawSet(p.prisonList[i])
    table.insert(players, player)
  end
  local params = {}
  params.players = players
  params.totalPage = p.pageTotal
  params.curPage = p.pageNo
  Event.DispatchEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.Prison.Receive_Prison_Data, params)
end
def.static("table").OnSJailDeliveryError = function(p)
  local JailAction = require("netio.protocol.mzm.gsp.prison.JailAction")
  local prisonName = _G.GetStringFromOcts(p.savedName)
  if p.errorCode == JailAction.JAIL_BREAK then
    Toast(string.format(textRes.PlayerPK.PlayerPrison.SJailDeliveryError[2], prisonName))
  elseif p.errorCode == JailAction.JAIL_DELIVERY then
    Toast(string.format(textRes.PlayerPK.PlayerPrison.SJailDeliveryError[3], prisonName))
  elseif p.errorCode == JailAction.OFF_LINE then
    Toast(string.format(textRes.PlayerPK.PlayerPrison.SJailDeliveryError[4], prisonName))
  elseif p.errorCode == JailAction.OUT_JAIL then
    Toast(string.format(textRes.PlayerPK.PlayerPrison.SJailDeliveryError[5], prisonName))
  else
    Toast(string.format(textRes.PlayerPK.PlayerPrison.SJailDeliveryError[-1], p.errorCode))
  end
end
def.static("table").OnSNotifyJailDeliveryBegin = function(p)
  local players = {}
  for i = 1, #(p.nameList or {}) do
    table.insert(players, _G.GetStringFromOcts(p.nameList[i]))
  end
  local prisonName = _G.GetStringFromOcts(p.name)
  local str = string.format(textRes.PlayerPK.PlayerPrison[13], table.concat(players, "\227\128\129"), prisonName)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.static("table").OnSNotifyJailDeliveryResult = function(p)
  local players = {}
  for i = 1, #(p.nameList or {}) do
    table.insert(players, _G.GetStringFromOcts(p.nameList[i]))
  end
  local prisonName = _G.GetStringFromOcts(p.name)
  local str
  local SNotifyJailDeliveryResult = require("netio.protocol.mzm.gsp.prison.SNotifyJailDeliveryResult")
  if p.result == SNotifyJailDeliveryResult.SUCCESS then
    str = string.format(textRes.PlayerPK.PlayerPrison[14], table.concat(players, "\227\128\129"), prisonName)
  else
    str = string.format(textRes.PlayerPK.PlayerPrison[15], table.concat(players, "\227\128\129"), prisonName)
  end
  if str ~= nil then
    AnnouncementTip.Announce(str)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  end
end
def.static("table").OnSNotifyPutInJail = function(p)
  Toast(textRes.PlayerPK.PlayerPrison[18])
end
def.static("table", "table").OnNpcService = function(p1, p2)
  local serviceId = p1[1]
  local npcId = p1[2]
  if npcId == constant.CPKConsts.PRISON_BREAK_NPC_ID then
    if serviceId == constant.CPKConsts.PRISON_SERVE_TIME_SERVICE_ID then
      PrisonMgr.Instance():QueryPrisonLeftTime()
    elseif serviceId == constant.CPKConsts.PRISON_BREAK_SERVICE_ID then
      PrisonMgr.Instance():AttendToEscape()
    end
  elseif npcId == constant.CPKConsts.PK_NPC_ID and serviceId == constant.CPKConsts.VISIT_PRISON_SERVICE_ID then
    PrisonMgr.Instance():GotoWatchPrison()
  elseif npcId == constant.CPKConsts.RESCUE_NPC_ID then
    if serviceId == constant.CPKConsts.RESCUE_SERVICE_ID then
      PrisonMgr.Instance():QueryToShowPrisonList()
    elseif serviceId == constant.CPKConsts.RETURN_SERVICE_ID then
      PrisonMgr.Instance():LeavePrison()
    end
  end
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_PRISON)
  return isOpen
end
def.static("=>", "boolean").CheckIsFeatureOpenAndToast = function()
  local isOpen = PrisonMgr.IsFeatureOpen()
  if not isOpen then
    Toast(textRes.PlayerPK.PlayerPrison[8])
    return false
  end
  return true
end
def.static("number", "=>", "boolean").OnNPCService_VisitPrison = function(serviceId)
  if serviceId == constant.CPKConsts.VISIT_PRISON_SERVICE_ID then
    local isOpen = PrisonMgr.IsFeatureOpen()
    if not isOpen then
      return false
    else
      return true
    end
  else
    return true
  end
end
def.method().QueryPrisonLeftTime = function(self)
  if not PrisonMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.prison.CGetInJailLeftTimeReq").new()
  gmodule.network.sendProtocol(req)
end
def.method().AttendToEscape = function(self)
  if not PrisonMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local needMoney = constant.CPKConsts.PRISON_BREAK_PRICE
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local moneyData = CurrencyFactory.Create(constant.CPKConsts.PRISON_BREAK_MONEY_TYPE)
  local function escape()
    if Int64.lt(moneyData:GetHaveNum(), needMoney) then
      moneyData:AcquireWithQuery()
      return
    end
    local req = require("netio.protocol.mzm.gsp.prison.CJailBreakReq").new()
    gmodule.network.sendProtocol(req)
  end
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.PlayerPK.PlayerPrison[2], string.format(textRes.PlayerPK.PlayerPrison[3], needMoney, moneyData:GetName()), function(result)
    if result == 1 then
      escape()
    end
  end, nil)
end
def.method().GotoWatchPrison = function(self)
  if not PrisonMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.prison.CEnterPrisonMapReq").new()
  gmodule.network.sendProtocol(req)
end
def.method().LeavePrison = function(self)
  if not PrisonMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.prison.CLeavePrisonMapReq").new()
  gmodule.network.sendProtocol(req)
end
def.method().QueryToShowPrisonList = function(self)
  if not PrisonMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local PrisonPlayerPanel = require("Main.PlayerPk.Prison.ui.PrisonPlayerPanel")
  PrisonPlayerPanel.Instance():ShowPanel()
end
def.method("number").QueryPrisonPlayerData = function(self, page)
  if not PrisonMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.prison.CPrisonListReq").new(page)
  gmodule.network.sendProtocol(req)
end
def.method("table").ResucuePlayer = function(self, player)
  if not PrisonMgr.CheckIsFeatureOpenAndToast() then
    return
  end
  local function rescue()
    local req = require("netio.protocol.mzm.gsp.prison.CJailDeliveryReq").new(player:GetPlayerId())
    gmodule.network.sendProtocol(req)
  end
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.PlayerPK.PlayerPrison[19], string.format(textRes.PlayerPK.PlayerPrison[20], player:GetName()), function(result)
    if result == 1 then
      rescue()
    end
  end, nil)
end
def.method("=>", "boolean").IsInPrisonMap = function(self)
  local curMapId = require("Main.Map.Interface").GetCurMapId()
  return curMapId == constant.CPKConsts.PRISON_MAP_ID
end
return PrisonMgr.Commit()
