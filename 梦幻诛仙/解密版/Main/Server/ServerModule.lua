local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ServerModule = Lplus.Extend(ModuleBase, "ServerModule")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local ServerLevelData = require("Main.Server.data.ServerLevelData")
local def = ServerModule.define
def.field(ServerLevelData)._serverLevelData = nil
def.field("userdata")._lastServerTime = nil
def.field("number")._lastClientTickCount = 0
def.field("boolean")._isServerShutDown = false
def.field("number")._newDayTimerID = 0
def.field("number")._nextDayTime = 0
def.field("table").m_Zoneids = nil
def.field("number")._debugTimeOffset = 0
local instance
def.static("=>", ServerModule).Instance = function()
  if instance == nil then
    instance = ServerModule()
    instance.m_moduleId = ModuleId.SERVER
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, ServerModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function(p1, p2)
    self:OnLeaveWorld(p1, p2)
  end)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.online.SSendServerTime", ServerModule.OnSSendServerTime)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.server.SSyncServerLevel", ServerModule.OnSSyncServerLevel)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.online.SServerShutDownBrd", ServerModule.OnSServerShutDownBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.online.SBrocastServerOpenTime", ServerModule.OnSBrocastServerOpenTime)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.online.SSyncServerMergeHistory", ServerModule.OnSyncServerMergeHistory)
end
def.method("=>", "boolean").IsServerShutDown = function(self)
  return self._isServerShutDown
end
def.method("=>", ServerLevelData).GetServerLevelInfo = function(self)
  return self._serverLevelData
end
def.method("=>", "userdata").GetNextServerLevelStartTime = function(self)
  if self._serverLevelData == nil then
    return Int64.new(0)
  end
  local nextStartTime = self._serverLevelData.upgradeTime
  return nextStartTime
end
def.method("=>", "number").GetOpenServerStartDayTime = function(self)
  local serverLevelData = self:GetServerLevelInfo()
  local serverOpenTime = serverLevelData.serverOpenTime
  if serverOpenTime <= 0 then
    return 0
  end
  local t = AbsoluteTimer.GetServerTimeTable(serverOpenTime)
  local openHour = t.hour
  local openMin = t.min
  local openSec = t.sec
  return serverOpenTime - openHour * 3600 - openMin * 60 - openSec
end
def.method("=>", "number").GetServerOpenDays = function(self)
  local openTime = self:GetOpenServerStartDayTime()
  if openTime == 0 then
    return 1
  end
  local durationTime = GetServerTime() - openTime
  durationTime = math.max(0, durationTime)
  local durationDay = math.ceil(durationTime / 86400)
  return durationDay
end
def.method("number").SetDebugTimeOffset = function(self, offset)
  self._debugTimeOffset = offset
end
def.method("=>", "number").GetDebugTimeOffset = function(self, offset)
  return self._debugTimeOffset
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:Reset()
  self:StopNewDayTimer()
end
def.static("table").OnSSendServerTime = function(p)
  if instance._serverLevelData == nil then
    instance._serverLevelData = ServerLevelData()
  end
  instance._serverLevelData.serverOpenTime = p.serverOpenTime:ToNumber()
  local nowSecond = Int64.ToNumber(p.serverTime)
  nowSecond = nowSecond + instance._debugTimeOffset
  if _G._debug_server_time then
    nowSecond = _G._debug_server_time
  end
  SetServerTime(nowSecond, p.raw_offset)
  instance:SetServerTime(Int64.new(nowSecond))
  instance._nextDayTime = instance:CalcNextDayTime(nowSecond)
end
def.method("number", "=>", "number").CalcNextDayTime = function(self, curTime)
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  local nowHour = t.hour
  local nowMinite = t.min
  local nowSec = math.floor(curTime % 60)
  nowSec = nowHour * 3600 + nowMinite * 60 + nowSec
  local remainTime = 86400 - nowSec
  local nextDayTime = curTime + remainTime
  return nextDayTime
end
def.method().StartNewDayTimer = function(self)
  self:StopNewDayTimer()
  self._newDayTimerID = GameUtil.AddGlobalTimer(1, false, function()
    self:_OnNewDayTimer()
  end)
end
def.method().StopNewDayTimer = function(self)
  if self._newDayTimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._newDayTimerID)
    self._newDayTimerID = 0
  end
end
def.method()._OnNewDayTimer = function(self)
  local curTime = _G.GetServerTime()
  if curTime >= self._nextDayTime then
    self._nextDayTime = self:CalcNextDayTime(curTime)
    warn(string.format(">>>>>>>>>>>>>>%d NEW_DAY %d>>>>>>>>>>>>>>>", curTime, self._nextDayTime))
    Event.DispatchEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, nil)
  end
end
def.method("userdata").SetServerTime = function(self, serverTickCount)
  self._lastServerTime = serverTickCount
  self._lastClientTickCount = GameUtil.GetTickCount()
end
def.method("=>", "userdata").GetServerTime = function(self, serverTickCount)
  local curTickCount = GameUtil.GetTickCount()
  return self._lastServerTime + math.floor((curTickCount - self._lastClientTickCount) / 1000)
end
def.method("=>", "userdata").GetMilliServerTime = function(self, serverTickCount)
  local curTickCount = GameUtil.GetTickCount()
  return self._lastServerTime * 1000 + curTickCount - self._lastClientTickCount
end
def.static("table").OnSSyncServerLevel = function(p)
  local self = instance
  if self._serverLevelData == nil then
    self._serverLevelData = ServerLevelData()
  end
  self._serverLevelData:RawSet(p)
  Event.DispatchEvent(ModuleId.SERVER, gmodule.notifyId.Server.SYNC_SERVER_LEVEL, nil)
end
def.static("table").OnSServerShutDownBrd = function(p)
  local delay = p.delay
  if delay <= 5 then
    instance._isServerShutDown = true
  end
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local ChatModule = require("Main.Chat.ChatModule")
  local text
  if delay >= 3600 then
    local value = math.floor(delay / 3600)
    text = string.format(textRes.Server[1], string.format(textRes.Server.Time.Hour, value))
  elseif delay >= 60 then
    local value = math.floor(delay / 60)
    text = string.format(textRes.Server[1], string.format(textRes.Server.Time.Minute, value))
  elseif delay > 0 then
    local value = delay
    text = string.format(textRes.Server[1], string.format(textRes.Server.Time.Second, value))
  else
    text = textRes.Server[2]
  end
  local isShowInChat = true
  ChatModule.Instance():SendSystemMsgEx(ChatMsgData.System.SYS, HtmlHelper.Style.System, {text = text}, isShowInChat)
end
def.static("table").OnSBrocastServerOpenTime = function(p)
  if instance._serverLevelData == nil then
    instance._serverLevelData = ServerLevelData()
  end
  instance._serverLevelData.serverOpenTime = p.serverOpenTime:ToNumber()
end
def.static("table").OnSyncServerMergeHistory = function(p)
  warn("OnSyncServerMergeHistory", #p.zoneids)
  instance.m_Zoneids = p.zoneids
end
def.static("table", "table").OnEnterWorld = function(params, context)
  local self = instance
  self:StartNewDayTimer()
  local enterType = params and params.enterType or 0
  if enterType == _G.EnterWorldType.RECONNECT then
    return
  end
  local serverLevelInfo = self:GetServerLevelInfo()
  if serverLevelInfo == nil or serverLevelInfo.reachMaxLevel then
    return
  end
  local nextStartTime = self:GetNextServerLevelStartTime()
  local serverTime = self:GetServerTime()
  local interval = nextStartTime - serverTime
  if interval:lt(0) then
    return
  end
  local HeroUtility = require("Main.Hero.HeroUtility")
  local showTipMaxMinute = HeroUtility.Instance():GetRoleCommonConsts("TIME_TO_NEXT_TIP")
  if interval > Int64.new(showTipMaxMinute * 60) then
    return
  end
  local tipId = HeroUtility.Instance():GetRoleCommonConsts("TIP_CONTENT")
  local content = require("Main.Common.TipsHelper").GetHoverTip(tipId) or ""
  local t = AbsoluteTimer.GetServerTimeTable(Int64.ToNumber(nextStartTime))
  local nextServerLevel = require("Main.Server.ServerUtility").GetNextServerLevel(self._serverLevelData.level)
  local nextServerLevelStr = string.format(textRes.Server[3], nextServerLevel)
  local nextTimeStr = string.format(textRes.Server[4], t.year, t.month, t.day, t.hour, t.min)
  content = string.format(content, nextServerLevelStr, nextTimeStr)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, content)
end
def.override().OnReset = function(self)
  self._isServerShutDown = false
end
return ServerModule.Commit()
