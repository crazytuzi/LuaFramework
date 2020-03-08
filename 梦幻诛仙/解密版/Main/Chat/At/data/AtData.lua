local Lplus = require("Lplus")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local ChannelAtData = require("Main.Chat.At.data.ChannelAtData")
local GroupData = require("Main.Group.data.GroupData")
local AtData = Lplus.Class("AtData")
local def = AtData.define
local _instance
def.static("=>", AtData).Instance = function()
  if _instance == nil then
    _instance = AtData()
  end
  return _instance
end
def.const("table").RECORD_AT_CHANNELS = {
  ChatConsts.CHANNEL_FACTION,
  ChatConsts.CHANNEL_TEAM,
  ChatConsts.CHANNEL_GROUP
}
def.field("table")._channelAtMsgMap = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._channelAtMsgMap = nil
end
def.method("number", "userdata", "table", "boolean").AddAtMsg = function(self, channel, orgId, msgData, bEvent)
  if _G.IsCrossingServer() then
    warn("[AtData:AddAtMsg] abandon at msg when crossing server.")
    return
  end
  if self._channelAtMsgMap == nil then
    self._channelAtMsgMap = {}
  end
  local channelAtData = self._channelAtMsgMap[channel]
  if nil == channelAtData then
    channelAtData = ChannelAtData.New(channel)
    self._channelAtMsgMap[channel] = channelAtData
  end
  channelAtData:AddAtMsg(orgId, msgData, bEvent)
end
def.method("table").RemoveAtMsg = function(self, atMsgData)
  warn("[AtData:RemoveAtMsg] RemoveAtMsg.")
  if atMsgData then
    local channel = atMsgData.channel
    local channelAtData = self:GetChannelAtMsg(channel)
    if channelAtData then
      channelAtData:RemoveAtMsg(atMsgData, true)
    end
  else
  end
end
def.method().RemoveAllAtMsg = function(self)
  warn("[AtData:RemoveAllAtMsg] RemoveAllAtMsg!")
  if self._channelAtMsgMap then
    for chanel, channelAtMsg in pairs(self._channelAtMsgMap) do
      channelAtMsg:RemoveAllAtMsg(false)
    end
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, nil)
  end
end
def.method("userdata").RemoveGroupAtMsg = function(self, groupId)
  warn("[AtData:RemoveGroupAtMsg] groupId:", groupId and Int64.tostring(groupId) or nil)
  local channelAtMsg = self:GetChannelAtMsg(ChatConsts.CHANNEL_GROUP)
  if channelAtMsg then
    channelAtMsg:RemoveOrgAtMsg(groupId, false)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, nil)
  end
end
def.method("number", "=>", "table").GetChannelAtMsg = function(self, channel)
  local result = self._channelAtMsgMap and self._channelAtMsgMap[channel]
  return result
end
def.method("number", "userdata", "=>", "table").GetOrgAtMsg = function(self, channel, orgId)
  local result
  local channelAtData = self:GetChannelAtMsg(channel)
  if channelAtData then
    result = channelAtData:GetOrgAtMsg(orgId)
  end
  return result
end
def.method("=>", "table").GetAllAtMsg = function(self)
  local result = {}
  if self._channelAtMsgMap then
    for chanel, channelAtMsg in pairs(self._channelAtMsgMap) do
      local atMsgs = channelAtMsg:_GetAllAtMsg()
      if atMsgs and #atMsgs > 0 then
        for _, atMsgData in ipairs(atMsgs) do
          table.insert(result, atMsgData)
        end
      end
    end
  end
  table.sort(result, function(a, b)
    if a == nil then
      return true
    elseif b == nil then
      return false
    elseif not Int64.eq(a:GetTimeStamp(), b:GetTimeStamp()) then
      return Int64.gt(a:GetTimeStamp(), b:GetTimeStamp())
    else
      return a:GetUniqueId() > b:GetUniqueId()
    end
  end)
  return result
end
def.method("number", "=>", "number").GetChannelMsgCount = function(self, channel)
  local result = 0
  if channel == ChatConsts.CHANNEL_GROUP then
    result = self:GetGroupAtMsgCount()
  elseif channel == ChatConsts.CHANNEL_FACTION then
    result = self:GetFactionAtMsgCount()
  elseif channel == ChatConsts.CHANNEL_TEAM then
    result = self:GetTeamAtMsgCount()
  else
    result = 0
  end
  return result
end
def.method("=>", "number").GetGroupAtMsgCount = function(self)
  local result = 0
  local GroupModule = require("Main.Group.GroupModule")
  local curGroupList = GroupModule.Instance():GetBasicGroupList()
  if curGroupList and #curGroupList > 0 then
    for _, basicInfo in pairs(curGroupList) do
      local isShield = GroupModule.Instance():GetMessageShildState(basicInfo.groupId)
      if not isShield then
        result = result + self:GetOrgMsgCount(ChatConsts.CHANNEL_GROUP, basicInfo.groupId)
      end
    end
  else
    local channelAtMsg = self:GetChannelAtMsg(ChatConsts.CHANNEL_GROUP)
    local groupOrgMap = channelAtMsg and channelAtMsg:_GetOrgAtMap()
    if groupOrgMap then
      for key, orgAtData in pairs(groupOrgMap) do
        local isShield = GroupModule.Instance():GetMessageShildState(orgAtData.orgId)
        if not isShield then
          result = result + orgAtData:GetMsgCount()
        end
      end
    end
  end
  return result
end
def.method("=>", "number").GetChatAtMsgCount = function(self)
  local result = 0
  for _, channel in pairs(AtData.RECORD_AT_CHANNELS) do
    if channel ~= ChatConsts.CHANNEL_GROUP then
      result = result + self:GetChannelMsgCount(channel)
    end
  end
  return result
end
def.method("=>", "number").GetFactionAtMsgCount = function(self)
  local GangData = require("Main.Gang.data.GangData")
  local orgId = GangData.Instance():GetGangId()
  return orgId and self:GetOrgMsgCount(ChatConsts.CHANNEL_FACTION, orgId) or 0
end
def.method("=>", "number").GetTeamAtMsgCount = function(self)
  local TeamData = require("Main.Team.TeamData")
  local orgId = TeamData.Instance().teamId
  return orgId and self:GetOrgMsgCount(ChatConsts.CHANNEL_TEAM, orgId) or 0
end
def.method("number", "userdata", "=>", "number").GetOrgMsgCount = function(self, channel, orgId)
  local orgAtData = self:GetOrgAtMsg(channel, orgId)
  local atMsgCount = orgAtData and orgAtData:GetMsgCount() or 0
  return atMsgCount
end
def.method().LoadAtMsgRecords = function(self)
  local AtUtils = require("Main.Chat.At.AtUtils")
  for _, channel in pairs(AtData.RECORD_AT_CHANNELS) do
    local maxAtMsgCount = AtUtils.GetChannelMaxAt(channel)
    if channel == ChatConsts.CHANNEL_GROUP then
      local maxGroupNum = AtUtils.GetMaxGroupNum()
      for orgRecordIdx = 0, maxGroupNum - 1 do
        self:_LoadOrgAtMsgs(channel, orgRecordIdx, maxAtMsgCount)
      end
    else
      self:_LoadOrgAtMsgs(channel, ChannelAtData.NONE_GROUP_ORG_IDX, maxAtMsgCount)
    end
  end
end
def.method("number", "number", "number")._LoadOrgAtMsgs = function(self, channel, orgRecordIdx, maxAtMsgCount)
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  local AtUtils = require("Main.Chat.At.AtUtils")
  local recordList = {}
  for msgRecordIdx = 0, maxAtMsgCount - 1 do
    local key = AtUtils.GetRecordKey(channel, orgRecordIdx, msgRecordIdx)
    if key and LuaPlayerPrefs.HasRoleKey(key) then
      warn("[AtData:_LoadOrgAtMsgs] load record with key:", key)
      local record = LuaPlayerPrefs.GetRoleTable(key)
      record.orgId = record.orgId and Int64.new(record.orgId) or 0
      record.timestamp = record.timestamp and Int64.new(record.timestamp) or 0
      record.roleId = record.roleId and Int64.new(record.roleId) or 0
      table.insert(recordList, record)
    end
  end
  if #recordList > 0 then
    table.sort(recordList, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      elseif not Int64.eq(a.timestamp, b.timestamp) then
        return Int64.lt(a.timestamp, b.timestamp)
      else
        return a.unique < b.unique
      end
    end)
    for _, record in ipairs(recordList) do
      self:AddAtMsgFromRecord(channel, record, false)
    end
  end
end
def.method("number", "table", "boolean").AddAtMsgFromRecord = function(self, channel, record, bEvent)
  if self._channelAtMsgMap == nil then
    self._channelAtMsgMap = {}
  end
  local channelAtData = self._channelAtMsgMap[channel]
  if nil == channelAtData then
    channelAtData = ChannelAtData.New(channel)
    self._channelAtMsgMap[channel] = channelAtData
  end
  channelAtData:AddAtMsgFromRecord(record, bEvent)
end
def.method().OnLeaveWorld = function(self)
  self:_Reset()
end
def.method("userdata").OnLeaveGroup = function(self, groupId)
  if groupId then
    self:RemoveGroupAtMsg(groupId)
  end
end
def.method().OnGroupInit = function(self)
  local channelAtMsg = self:GetChannelAtMsg(ChatConsts.CHANNEL_GROUP)
  local orgAtMsgMap = channelAtMsg and channelAtMsg:_GetOrgAtMap() or nil
  if orgAtMsgMap then
    local bEvent = false
    for _, orgAtData in pairs(orgAtMsgMap) do
      local groupId = orgAtData.orgId
      if not GroupData.Instance():IsGroupExist(groupId) then
        warn("[AtData:OnGroupInit] remove at msgs of lost group:", groupId and Int64.tostring(groupId) or nil)
        channelAtMsg:RemoveOrgAtMsg(groupId, false)
        bEvent = true
      end
    end
    if bEvent then
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, nil)
    end
  end
end
def.method().OnTeamChange = function(self)
  local channelAtMsg = self:GetChannelAtMsg(ChatConsts.CHANNEL_TEAM)
  if channelAtMsg then
    local TeamData = require("Main.Team.TeamData")
    local orgId = TeamData.Instance().teamId
    channelAtMsg:ClearOrgAtMsgsExcept(orgId, true)
  end
end
def.method().OnGangChange = function(self)
  local channelAtMsg = self:GetChannelAtMsg(ChatConsts.CHANNEL_FACTION)
  if channelAtMsg then
    local GangData = require("Main.Gang.data.GangData")
    local orgId = GangData.Instance():GetGangId()
    channelAtMsg:ClearOrgAtMsgsExcept(orgId, true)
  end
end
AtData.Commit()
return AtData
