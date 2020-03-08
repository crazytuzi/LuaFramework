local OctetsStream = require("netio.OctetsStream")
local GrcUserSendGiftInfo = class("GrcUserSendGiftInfo")
function GrcUserSendGiftInfo:ctor(gift_type, today_send_gift_infos)
  self.gift_type = gift_type or nil
  self.today_send_gift_infos = today_send_gift_infos or {}
end
function GrcUserSendGiftInfo:marshal(os)
  os:marshalInt32(self.gift_type)
  os:marshalCompactUInt32(table.getn(self.today_send_gift_infos))
  for _, v in ipairs(self.today_send_gift_infos) do
    v:marshal(os)
  end
end
function GrcUserSendGiftInfo:unmarshal(os)
  self.gift_type = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.GrcSendGiftInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.today_send_gift_infos, v)
  end
end
return GrcUserSendGiftInfo
