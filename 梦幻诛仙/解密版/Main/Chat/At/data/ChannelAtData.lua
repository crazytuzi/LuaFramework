local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OrgAtData = require("Main.Chat.At.data.OrgAtData")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local AtMsgData = require("Main.Chat.At.data.AtMsgData")
local ChannelAtData = Lplus.Class(CUR_CLASS_NAME)
local def = ChannelAtData.define
def.const("string").DEFAULT_KEY = "0"
def.const("string").NONE_GROUP_KEY = "0"
def.const("number").NONE_GROUP_ORG_IDX = 0
def.field("number").channel = 0
def.field("number").maxAtNum = 0
def.field("table")._orgAtMap = nil
def.field("number")._curOrgRecordIdx = 0
def.field("table")._orgRecordIdxMap = nil
def.final("number", "=>", ChannelAtData).New = function(channel)
  local channelAtData = ChannelAtData()
  channelAtData.channel = channel
  channelAtData.maxAtNum = require("Main.Chat.At.AtUtils").GetChannelMaxAt(channel)
  channelAtData._orgAtMap = {}
  channelAtData._curOrgRecordIdx = 0
  channelAtData._orgRecordIdxMap = {}
  return channelAtData
end
def.method().Release = function(self)
  self._orgAtMap = nil
  self._curOrgRecordIdx = 0
  self._orgRecordIdxMap = nil
end
def.method("=>", "number").GetMsgCount = function(self)
  local result = 0
  if self._orgAtMap then
    for key, orgAtData in pairs(self._orgAtMap) do
      result = result + orgAtData:GetMsgCount()
    end
  end
  return result
end
def.method("userdata", "table", "boolean").AddAtMsg = function(self, orgId, msgData, bEvent)
  if nil == orgId or nil == msgData then
    warn("[ERROR][ChannelAtData:AddAtMsg] add fail! orgId or msgData nil:", orgId, msgData)
    return
  end
  if self._orgAtMap == nil then
    self._orgAtMap = {}
  end
  local key = self:GetOrgKey(orgId)
  warn(string.format("[ChannelAtData:AddAtMsg] channel=%d, orgId=%s.", self.channel, key))
  local orgAtData = self._orgAtMap[key]
  if nil == orgAtData then
    if self.channel ~= ChatConsts.CHANNEL_GROUP then
      self:ClearOrgAtMsgsExcept(orgId, false)
    end
    local orgRecordIdx = self:_GetOrgRecordIdx(orgId)
    orgAtData = OrgAtData.New(self.channel, orgId, self.maxAtNum, orgRecordIdx)
    self._orgAtMap[key] = orgAtData
  end
  orgAtData:PushAtMsg(msgData, bEvent)
end
def.method("userdata", "=>", "string").GetOrgKey = function(self, orgId)
  local key = ChannelAtData.DEFAULT_KEY
  if orgId then
    key = Int64.tostring(orgId)
  end
  return key
end
def.method("userdata", "=>", "table").GetOrgAtMsg = function(self, orgId)
  local result
  local key = self:GetOrgKey(orgId)
  local result = self._orgAtMap and self._orgAtMap[key]
  return result
end
def.method("userdata", "boolean").RemoveOrgAtMsg = function(self, orgId, bEvent)
  if orgId then
    local orgAtData = self:GetOrgAtMsg(orgId)
    if orgAtData then
      orgAtData:RemoveAllAtMsg(bEvent)
      self:_SetOrgRecordIdx(orgAtData.orgRecordIdx, nil)
    end
    local key = self:GetOrgKey(orgId)
    self._orgAtMap[key] = nil
  end
end
def.method("table", "boolean").RemoveAtMsg = function(self, atMsgData, bEvent)
  if nil == atMsgData then
    warn("[ERROR][ChannelAtData:RemoveAtMsg] atMsgData nil.")
    return
  end
  local orgAtData = self:GetOrgAtMsg(atMsgData.orgId)
  if orgAtData == nil then
    warn(string.format("[ERROR][ChannelAtData:RemoveAtMsg] orgAtData nil: channel=%d, orgId=", self.channel), atMsgData.orgId and Int64.tostring(atMsgData.orgId))
    return
  end
  warn(string.format("[ChannelAtData:RemoveAtMsg] RemoveAtMsg: channel=%d, orgId=", self.channel), atMsgData.orgId and Int64.tostring(atMsgData.orgId))
  orgAtData:RemoveAtMsg(atMsgData, bEvent)
end
def.method("=>", "table")._GetAllAtMsg = function(self)
  local result = {}
  if self._orgAtMap then
    for key, orgAtMsg in pairs(self._orgAtMap) do
      local atMsgs = orgAtMsg:_GetAllAtMsg()
      if atMsgs and #atMsgs > 0 then
        for _, atMsgData in ipairs(atMsgs) do
          table.insert(result, atMsgData)
        end
      end
    end
  end
  return result
end
def.method("boolean").RemoveAllAtMsg = function(self, bEvent)
  if self._orgAtMap then
    for key, orgAtMsg in pairs(self._orgAtMap) do
      orgAtMsg:RemoveAllAtMsg(bEvent)
    end
  end
end
def.method("=>", "table")._GetOrgAtMap = function(self)
  return self._orgAtMap
end
def.method("userdata", "boolean").ClearOrgAtMsgsExcept = function(self, newOrgId, bEvent)
  warn("[ChannelAtData:ClearOrgAtMsgsExcept] newOrgId:", newOrgId and Int64.tostring(newOrgId))
  local deleteOrgList = {}
  local count = 0
  for oldKey, oldOrgAtData in pairs(self._orgAtMap) do
    if nil == newOrgId or not Int64.eq(oldOrgAtData.orgId, newOrgId) then
      table.insert(deleteOrgList, oldOrgAtData.orgId)
      count = count + 1
    end
  end
  if count > 0 then
    for _, orgId in ipairs(deleteOrgList) do
      warn(string.format("[ChannelAtData:ClearOrgAtMsgsExcept] delete invalid org atmsgs: channel=%d, orgId=", self.channel), orgId and Int64.tostring(orgId))
      self:RemoveOrgAtMsg(orgId, false)
    end
  end
  deleteOrgList = nil
  if bEvent then
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, nil)
  end
end
def.method("userdata", "=>", "number")._GetOrgRecordIdx = function(self, orgId)
  if self.channel == ChatConsts.CHANNEL_GROUP then
    local GroupData = require("Main.Group.data.GroupData")
    local maxGroupNum = require("Main.Chat.At.AtUtils").GetMaxGroupNum()
    if maxGroupNum == nil or maxGroupNum <= 1 then
      return 0
    end
    local iterCount = 1
    local iterIdx = self._curOrgRecordIdx % maxGroupNum
    while self._orgRecordIdxMap[iterIdx] and GroupData.Instance():IsGroupExist(self._orgRecordIdxMap[iterIdx]) and maxGroupNum >= iterCount do
      iterCount = iterCount + 1
      iterIdx = (iterIdx + 1) % maxGroupNum
    end
    if maxGroupNum < iterCount then
      iterIdx = self._curOrgRecordIdx % maxGroupNum
    else
    end
    self._curOrgRecordIdx = (iterIdx + 1) % maxGroupNum
    self:_SetOrgRecordIdx(iterIdx, orgId)
    return iterIdx
  else
    return ChannelAtData.NONE_GROUP_ORG_IDX
  end
end
def.method("number", "userdata")._SetOrgRecordIdx = function(self, orgRecordIdx, orgId)
  if self.channel == ChatConsts.CHANNEL_GROUP then
    self._orgRecordIdxMap[orgRecordIdx] = orgId
  end
end
def.method("table", "boolean").AddAtMsgFromRecord = function(self, atRecord, bEvent)
  if nil == atRecord then
    warn("[ERROR][ChannelAtData:AddAtMsgFromRecord] add fail! atRecord nil.")
    return
  end
  if self._orgAtMap == nil then
    self._orgAtMap = {}
  end
  local orgId = atRecord.orgId
  local key = self:GetOrgKey(orgId)
  warn(string.format("[ChannelAtData:AddAtMsgFromRecord] channel=%d, orgId=%s.", self.channel, key))
  local orgAtData = self._orgAtMap[key]
  if nil == orgAtData then
    local orgRecordIdx = atRecord.orgRecordIdx
    self:_SetOrgRecordIdx(orgRecordIdx, orgId)
    orgAtData = OrgAtData.New(self.channel, orgId, self.maxAtNum, orgRecordIdx)
    self._orgAtMap[key] = orgAtData
  end
  orgAtData:PushAtMsgFromRecord(atRecord, bEvent)
end
return ChannelAtData.Commit()
