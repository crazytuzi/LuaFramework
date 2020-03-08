local SMailInitData = class("SMailInitData")
SMailInitData.TYPEID = 12592906
function SMailInitData:ctor(mailDatas)
  self.id = 12592906
  self.mailDatas = mailDatas or {}
end
function SMailInitData:marshal(os)
  os:marshalCompactUInt32(table.getn(self.mailDatas))
  for _, v in ipairs(self.mailDatas) do
    v:marshal(os)
  end
end
function SMailInitData:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.mail.MailData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.mailDatas, v)
  end
end
function SMailInitData:sizepolicy(size)
  return size <= 65535
end
return SMailInitData
