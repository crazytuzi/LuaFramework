local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AtMsgData = require("Main.Chat.At.data.AtMsgData")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local OrgAtData = Lplus.Class(CUR_CLASS_NAME)
local def = OrgAtData.define
def.field("number").channel = 0
def.field("userdata").orgId = nil
def.field("number").maxAtNum = 0
def.field("table")._atMsgList = nil
def.field("number").orgRecordIdx = 0
def.field("number")._curMsgRecordIdx = 0
def.field("table")._msgRecordIdxMap = nil
def.final("number", "userdata", "number", "number", "=>", OrgAtData).New = function(channel, orgId, maxAtNum, orgRecordIdx)
  local orgAtData = OrgAtData()
  orgAtData.channel = channel
  orgAtData.orgId = orgId
  orgAtData.maxAtNum = maxAtNum
  orgAtData._atMsgList = {}
  orgAtData.orgRecordIdx = orgRecordIdx
  orgAtData._curMsgRecordIdx = 0
  orgAtData._msgRecordIdxMap = {}
  return orgAtData
end
def.method().Release = function(self)
  self.orgId = nil
  self._atMsgList = nil
end
def.method("=>", "number").GetMsgCount = function(self)
  return self._atMsgList and #self._atMsgList or 0
end
def.method("table", "boolean").PushAtMsg = function(self, msgData, bEvent)
  if self.maxAtNum <= 0 then
    warn("[ERROR][OrgAtData:PushAtMsg] maxAtNum 0 for channel, orgId:", self.channel, self.orgId)
    return
  end
  if nil == msgData then
    warn("[ERROR][OrgAtData:PushAtMsg] add fail! msgData nil.")
    return
  end
  while self:GetMsgCount() >= self.maxAtNum do
    local oldMsg = self:_RemoveAtMsg(1, false)
    warn("[OrgAtData:PushAtMsg] msg stack full, remove old atMsgData:", oldMsg.channel, oldMsg.orgId and Int64.tostring(oldMsg.orgId))
  end
  local msgRecordIdx = self:_GetMsgRecordIdx()
  local atMsgData = AtMsgData.New(self.channel, self.orgId, msgData, msgRecordIdx, self.orgRecordIdx)
  warn(string.format("[OrgAtData:PushAtMsg] channel=%d, orgId=%s, msgRecordIdx=%d.", self.channel, self.orgId and Int64.tostring(self.orgId) or "nil", msgRecordIdx))
  self:_AddAtMsg(atMsgData, bEvent, true)
end
def.method("=>", AtMsgData).PopAtMsg = function(self)
  local result
  local count = self:GetMsgCount()
  if count > 0 then
    result = self:_RemoveAtMsg(count, true)
  end
  if result then
    warn("[OrgAtData:PopAtMsg] Pop atMsgData:", result.channel, result.orgId and Int64.tostring(result.orgId))
  else
    warn("[OrgAtData:PopAtMsg] pop fail, result nil.")
  end
  return result
end
def.method("=>", AtMsgData).GetLatestAtMsg = function(self)
  local result
  local count = self:GetMsgCount()
  if count > 0 then
    result = self._atMsgList[count]
  end
  return result
end
def.method("=>", "table")._GetAllAtMsg = function(self)
  return self._atMsgList
end
def.method(AtMsgData, "boolean", "boolean")._AddAtMsg = function(self, atMsgData, bEvent, bRecord)
  if nil == atMsgData then
    warn("[ERROR][OrgAtData:_AddAtMsg] add fail! atMsgData nil.")
    return
  end
  if self._atMsgList == nil then
    self._atMsgList = {}
  end
  table.insert(self._atMsgList, atMsgData)
  if bRecord then
    atMsgData:SaveRecord()
  end
  if bEvent then
    local params
    if atMsgData.channel == ChatConsts.CHANNEL_GROUP then
      params = {
        groupId = atMsgData.orgId
      }
    end
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, params)
  else
  end
end
def.method("number", "boolean", "=>", AtMsgData)._RemoveAtMsg = function(self, idx, bEvent)
  local result
  if idx > 0 and idx <= self:GetMsgCount() then
    result = table.remove(self._atMsgList, idx)
    self:_SetMsgRecordIdx(result.msgRecordIdx, false)
    result:ClearRecord()
    if bEvent then
      local params
      if result and result.channel == ChatConsts.CHANNEL_GROUP then
        params = {
          groupId = result.orgId
        }
      end
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, params)
    end
  else
  end
  return result
end
def.method(AtMsgData, "boolean").RemoveAtMsg = function(self, atMsgData, bEvent)
  if nil == atMsgData then
    warn("[ERROR][OrgAtData:RemoveAtMsg] atMsgData nil.")
    return
  end
  warn(string.format("[OrgAtData:RemoveAtMsg] channel=%d, orgId=", self.channel), self.orgId and Int64.tostring(self.orgId))
  local msgCount = self:GetMsgCount()
  if msgCount > 0 then
    local idx = 0
    for i = msgCount, 1, -1 do
      local msgData = self._atMsgList[i]
      if AtMsgData.eq(atMsgData, msgData) then
        idx = i
        break
      end
    end
    self:_RemoveAtMsg(idx, bEvent)
  end
end
def.method("boolean").RemoveAllAtMsg = function(self, bEvent)
  local msgCount = self:GetMsgCount()
  if msgCount > 0 then
    for idx = msgCount, 1, -1 do
      self:_RemoveAtMsg(idx, false)
    end
    if bEvent then
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, nil)
    end
  end
end
def.method("=>", "number")._GetMsgRecordIdx = function(self)
  if self.maxAtNum == nil or self.maxAtNum <= 1 then
    return 1
  end
  local iterCount = 1
  local iterIdx = self._curMsgRecordIdx % self.maxAtNum
  while self._msgRecordIdxMap[iterIdx] and iterCount <= self.maxAtNum do
    iterCount = iterCount + 1
    iterIdx = (iterIdx + 1) % self.maxAtNum
  end
  if iterCount > self.maxAtNum then
    iterIdx = self._curMsgRecordIdx % self.maxAtNum
  else
  end
  self._curMsgRecordIdx = (iterIdx + 1) % self.maxAtNum
  self:_SetMsgRecordIdx(iterIdx, true)
  return iterIdx
end
def.method("number", "boolean")._SetMsgRecordIdx = function(self, msgRecordIdx, value)
  self._msgRecordIdxMap[msgRecordIdx] = value
end
def.method("table", "boolean").PushAtMsgFromRecord = function(self, record, bEvent)
  if self.maxAtNum <= 0 then
    warn("[ERROR][OrgAtData:PushAtMsgFromRecord] maxAtNum 0 for channel:", self.channel)
    return
  end
  if nil == record then
    warn("[ERROR][OrgAtData:PushAtMsgFromRecord] add fail! record nil.")
    return
  end
  warn(string.format("[OrgAtData:PushAtMsgFromRecord] channel=%d, orgId=", self.channel), self.orgId and Int64.tostring(self.orgId))
  local msgRecordIdx = record.msgRecordIdx
  self:_SetMsgRecordIdx(msgRecordIdx, true)
  local atMsgData = AtMsgData.Unmarshal(record)
  self:_AddAtMsg(atMsgData, bEvent, false)
  while self:GetMsgCount() > self.maxAtNum do
    local oldMsg = self:_RemoveAtMsg(1, false)
    warn("[OrgAtData:PushAtMsgFromRecord] msg stack full, remove old atMsgData:", oldMsg.channel, oldMsg.orgId and Int64.tostring(oldMsg.orgId))
  end
end
return OrgAtData.Commit()
