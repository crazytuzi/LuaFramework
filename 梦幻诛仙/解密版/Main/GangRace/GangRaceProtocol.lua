local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GangRaceProtocol = Lplus.Class(MODULE_NAME)
local GangRaceModule = Lplus.ForwardDeclare("GangRaceModule")
local def = GangRaceProtocol.define
def.static().Init = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangrace.SRaceStatusRes", GangRaceProtocol.OnRaceStatusRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangrace.SVoteSuccess", GangRaceProtocol.OnVoteSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangrace.SPlayerInfoRes", GangRaceProtocol.OnPlayerInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangrace.SVotingStatusRes", GangRaceProtocol.OnVotingStatusRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangrace.SRunningInfoRes", GangRaceProtocol.OnRunningInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangrace.SRaceAwardRes", GangRaceProtocol.OnRaceAwardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangrace.SRaceStart", GangRaceProtocol.OnRaceStart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangrace.SErrorInfoRes", GangRaceProtocol.OnErrorInfoRes)
end
def.static("table").OnRaceStatusRes = function(p)
  local beginTime = GetServerTime() - p.beginTime
  warn(string.format("---------------------------------------OnRaceStatusRes: status=%d, begintime=%d, [%d/%d]", p.statuscode, beginTime, p.curCount, p.maxCount))
  Event.DispatchEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_RaceStatus, p)
end
def.static("table").OnVoteSuccess = function(p)
  Toast(textRes.GangRace[1])
  Event.DispatchEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_VoteSuccess, p.myVoteInfo)
  Event.DispatchEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_VoteStatus, p)
end
def.static("table").OnPlayerInfoRes = function(p)
  Event.DispatchEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_PlayerInfo, p.playerInfos)
end
def.static("table").OnVotingStatusRes = function(p)
  Event.DispatchEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_VoteStatus, p)
end
def.static("table").OnRunningInfoRes = function(p)
  local beginTime = GetServerTime() - p.beginTime
  Event.DispatchEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_RunningInfo, {
    beginTime = beginTime,
    playerAction = p.runningInfos,
    winIdx = p.ranks[1]
  })
end
def.static("table").OnErrorInfoRes = function(p)
  warn("---------------------------------------OnErrorInfoRes", p.resultcode)
  local moduleInstance = GangRaceModule.Instance()
  if moduleInstance._dlg then
    moduleInstance._dlg.bWaitData = false
  end
  local errorDes = textRes.GangRace.ErrorCode[p.resultcode]
  if errorDes then
    Toast(errorDes)
  end
end
def.static("table").OnRaceAwardRes = function(p)
  Toast(textRes.GangRace[6])
end
def.static("table").OnRaceStart = function(p)
  local display = string.format(textRes.GangRace[7], p.curCount + 1)
  local button = string.format("<a href='btn_gangracenpc' id=btn_gangracenpc><font color=#%s><u>[%s]</u></font></a>", link_defalut_color, textRes.GangRace[10])
  local str = string.format("%s%s", display, button)
  GangRaceProtocol.ShowInGangChannel(str)
  Event.DispatchEvent(ModuleId.GANGRACE, gmodule.notifyId.GangRace.GangRace_RaceStart, {
    curCount = p.curCount,
    maxCount = p.maxCount
  })
end
def.static().sendGetPlayerInfoReq = function()
  local p = require("netio.protocol.mzm.gsp.gangrace.CGetPlayerInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static().sendGetRaceStatus = function()
  local p = require("netio.protocol.mzm.gsp.gangrace.CRaceStatusReq").new()
  gmodule.network.sendProtocol(p)
end
def.static().sendGetVoteStatusReq = function()
  local p = require("netio.protocol.mzm.gsp.gangrace.CGetVoteStatusReq").new()
  gmodule.network.sendProtocol(p)
end
def.static().sendGetRunningInfoReq = function()
  local p = require("netio.protocol.mzm.gsp.gangrace.CGetRunningInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").sendRaceVote = function(_playerIndex, _voteCount)
  local p = require("netio.protocol.mzm.gsp.gangrace.CVoteReq").new(_playerIndex, _voteCount)
  gmodule.network.sendProtocol(p)
end
def.static("string").ShowInGangChannel = function(display)
  local gangId = require("Main.Gang.data.GangData").Instance():GetGangId()
  if gangId then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(display, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  end
end
return GangRaceProtocol.Commit()
