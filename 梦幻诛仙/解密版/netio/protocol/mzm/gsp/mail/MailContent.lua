local OctetsStream = require("netio.OctetsStream")
local MailContent = class("MailContent")
MailContent.TYPE_MAIL_FULL_CFG = 1
MailContent.TYPE_MAIL_AUTO = 2
MailContent.TYPE_MAIL_CFG = 3
MailContent.CONTENT_MAIL_CFG_ID = 51
MailContent.CONTENT_MAIL_TITLE = 52
MailContent.CONTENT_MAIL_TYPE = 53
MailContent.CONTENT_MAIL_CONTENT = 54
MailContent.FORMAT_STRING_TITLE = 201
MailContent.FORMAT_STRING_CONTENT = 202
function MailContent:ctor(mailContentType, contentMap, formatArgsMap)
  self.mailContentType = mailContentType or nil
  self.contentMap = contentMap or {}
  self.formatArgsMap = formatArgsMap or {}
end
function MailContent:marshal(os)
  os:marshalInt32(self.mailContentType)
  do
    local _size_ = 0
    for _, _ in pairs(self.contentMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.contentMap) do
      os:marshalInt32(k)
      os:marshalString(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.formatArgsMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.formatArgsMap) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function MailContent:unmarshal(os)
  self.mailContentType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalString()
    self.contentMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.mail.FormatArgs")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.formatArgsMap[k] = v
  end
end
return MailContent
