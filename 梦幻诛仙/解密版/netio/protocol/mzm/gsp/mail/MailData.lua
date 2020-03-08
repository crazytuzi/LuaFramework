local OctetsStream = require("netio.OctetsStream")
local MailContent = require("netio.protocol.mzm.gsp.mail.MailContent")
local MailData = class("MailData")
MailData.EXTRA_KEY_MAIL_DEL_TIME_SEC = 1
MailData.EXTRA_KEY_ZERO_PROFIT = 2
function MailData:ctor(mailIndex, mailContent, readState, createTime, hasThing, extraparam)
  self.mailIndex = mailIndex or nil
  self.mailContent = mailContent or MailContent.new()
  self.readState = readState or nil
  self.createTime = createTime or nil
  self.hasThing = hasThing or nil
  self.extraparam = extraparam or {}
end
function MailData:marshal(os)
  os:marshalInt32(self.mailIndex)
  self.mailContent:marshal(os)
  os:marshalInt32(self.readState)
  os:marshalInt32(self.createTime)
  os:marshalInt32(self.hasThing)
  local _size_ = 0
  for _, _ in pairs(self.extraparam) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.extraparam) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function MailData:unmarshal(os)
  self.mailIndex = os:unmarshalInt32()
  self.mailContent = MailContent.new()
  self.mailContent:unmarshal(os)
  self.readState = os:unmarshalInt32()
  self.createTime = os:unmarshalInt32()
  self.hasThing = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.extraparam[k] = v
  end
end
return MailData
