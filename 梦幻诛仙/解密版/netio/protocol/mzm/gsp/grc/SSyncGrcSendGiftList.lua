local SSyncGrcSendGiftList = class("SSyncGrcSendGiftList")
SSyncGrcSendGiftList.TYPEID = 12600322
function SSyncGrcSendGiftList:ctor(user_send_gift_infos)
  self.id = 12600322
  self.user_send_gift_infos = user_send_gift_infos or {}
end
function SSyncGrcSendGiftList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.user_send_gift_infos))
  for _, v in ipairs(self.user_send_gift_infos) do
    v:marshal(os)
  end
end
function SSyncGrcSendGiftList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.GrcUserSendGiftInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.user_send_gift_infos, v)
  end
end
function SSyncGrcSendGiftList:sizepolicy(size)
  return size <= 65535
end
return SSyncGrcSendGiftList
