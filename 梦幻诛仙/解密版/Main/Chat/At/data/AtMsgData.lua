local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local AtMsgData = Lplus.Class(CUR_CLASS_NAME)
local def = AtMsgData.define
def.field("number").channel = 0
def.field("userdata").orgId = nil
def.field("number").msgRecordIdx = 0
def.field("number").orgRecordIdx = 0
def.field("table")._msg = nil
def.final("number", "userdata", "table", "number", "number", "=>", AtMsgData).New = function(channel, orgId, msg, msgRecordIdx, orgRecordIdx)
  local atMsgData = AtMsgData()
  atMsgData.channel = channel
  atMsgData.orgId = orgId
  atMsgData._msg = msg
  atMsgData.msgRecordIdx = msgRecordIdx
  atMsgData.orgRecordIdx = orgRecordIdx
  return atMsgData
end
def.method().Release = function(self)
  self.orgId = nil
  self._msg = nil
end
def.static(AtMsgData, AtMsgData, "=>", "boolean").eq = function(msga, msgb)
  local result = false
  result = msga and msgb and msga.channel == msgb.channel and Int64.eq(msga.orgId, msgb.orgId) and Int64.eq(msga:GetTimeStamp(), msgb:GetTimeStamp()) and Int64.eq(msga:GetRoleId(), msgb:GetRoleId()) and msga:GetContent() == msgb:GetContent()
  return result
end
def.method("=>", "userdata").GetTimeStamp = function(self)
  return self._msg and self._msg.timestamp or nil
end
def.method("=>", "userdata").GetRoleId = function(self)
  return self._msg and self._msg.roleId or 0
end
def.method("=>", "string").GetRoleName = function(self)
  return self._msg and self._msg.roleName or ""
end
def.method("=>", "number").GetGender = function(self)
  return self._msg and self._msg.gender or 0
end
def.method("=>", "number").GetLevel = function(self)
  return self._msg and self._msg.level or 0
end
def.method("=>", "number").GetOccpId = function(self)
  return self._msg and self._msg.occupationId or 0
end
def.method("=>", "number").GetAvatarId = function(self)
  return self._msg and self._msg.avatarId or 0
end
def.method("=>", "number").GetUniqueId = function(self)
  return self._msg and self._msg.unique or 0
end
def.method("=>", "string").GetContent = function(self)
  return self._msg and self._msg.content or ""
end
def.method("=>", "string").GetPlainHtml = function(self)
  return self._msg and self._msg.plainHtml or ""
end
def.method("=>", "number").GetMsgType = function(self)
  return self._msg and self._msg.type or -1
end
def.method("=>", "number").GetContentType = function(self)
  return self._msg and self._msg.contentType or -1
end
def.method("=>", "number").GetAvatarFrame = function(self)
  return self._msg and self._msg.avatarFrameId or 0
end
def.method("table", "=>", "boolean").EqualWithMsg = function(self, msg)
  if nil == msg or nil == self._msg then
    return false
  elseif msg.type ~= self:GetMsgType() then
    return false
  elseif msg.contentType ~= ChatConsts.CONTENT_NORMAL or self:GetContentType() ~= ChatConsts.CONTENT_NORMAL then
    return false
  end
  local result = true
  if self.channel == ChatConsts.CHANNEL_GROUP then
    result = Int64.eq(msg.id, self.orgId)
  else
    result = msg.id == self.channel
  end
  result = result and nil ~= msg.timestamp and nil ~= self:GetTimeStamp() and Int64.eq(msg.timestamp, self:GetTimeStamp()) and Int64.eq(msg.roleId, self:GetRoleId()) and msg.content == self:GetContent()
  return result
end
def.method().SaveRecord = function(self)
  local key = self:GetRecordKey()
  warn("[AtMsgData:SaveRecord] save key:", key)
  local record = self:_Marshal()
  LuaPlayerPrefs.SetRoleTable(key, record)
  LuaPlayerPrefs.Save()
end
def.method().ClearRecord = function(self)
  local key = self:GetRecordKey()
  if key and LuaPlayerPrefs.HasRoleKey(key) then
    warn("[AtMsgData:ClearRecord] clear key:", key)
    LuaPlayerPrefs.DeleteRoleKey(key)
    LuaPlayerPrefs.Save()
  else
    warn("[ERROR][AtMsgData:ClearRecord] no role key:", key)
  end
end
def.method("=>", "string").GetRecordKey = function(self)
  return require("Main.Chat.At.AtUtils").GetRecordKey(self.channel, self.orgRecordIdx, self.msgRecordIdx)
end
def.method("=>", "table")._Marshal = function(self)
  local record = {}
  record.channel = self.channel
  record.orgId = self.orgId
  record.msgRecordIdx = self.msgRecordIdx
  record.orgRecordIdx = self.orgRecordIdx
  record.timestamp = self:GetTimeStamp()
  record.roleId = self:GetRoleId()
  record.roleName = self:GetRoleName()
  record.gender = self:GetGender()
  record.level = self:GetLevel()
  record.occupationId = self:GetOccpId()
  record.avatarId = self:GetAvatarId()
  record.unique = self:GetUniqueId()
  record.content = self:GetContent()
  record.plainHtml = self:GetPlainHtml()
  record.type = self:GetMsgType()
  record.contentType = self:GetContentType()
  record.avatarFrameId = self:GetAvatarFrame()
  return record
end
def.static("table", "=>", AtMsgData).Unmarshal = function(record)
  if nil == record then
    return nil
  end
  local channel = record.channel
  local orgId = record.orgId
  local msgRecordIdx = record.msgRecordIdx
  local orgRecordIdx = record.orgRecordIdx
  warn("[AtMsgData:Unmarshal] channel, orgId, orgRecordIdx, msgRecordIdx:", channel, orgId and Int64.tostring(orgId) or nil, orgRecordIdx, msgRecordIdx)
  local msg = {}
  msg.timestamp = record.timestamp
  msg.roleId = record.roleId
  msg.roleName = record.roleName
  msg.gender = record.gender
  msg.level = record.level
  msg.occupationId = record.occupationId
  msg.avatarId = record.avatarId
  msg.unique = record.unique
  msg.content = record.content
  msg.plainHtml = record.plainHtml
  msg.type = record.type
  msg.contentType = record.contentType
  msg.avatarFrameId = record.avatarFrameId
  return AtMsgData.New(channel, orgId, msg, msgRecordIdx, orgRecordIdx)
end
return AtMsgData.Commit()
