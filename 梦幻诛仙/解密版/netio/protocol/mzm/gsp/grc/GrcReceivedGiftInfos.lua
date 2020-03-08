local OctetsStream = require("netio.OctetsStream")
local GrcReceivedGiftInfos = class("GrcReceivedGiftInfos")
function GrcReceivedGiftInfos:ctor(gift_type, receive_times, serialids)
  self.gift_type = gift_type or nil
  self.receive_times = receive_times or nil
  self.serialids = serialids or {}
end
function GrcReceivedGiftInfos:marshal(os)
  os:marshalInt32(self.gift_type)
  os:marshalInt32(self.receive_times)
  os:marshalCompactUInt32(table.getn(self.serialids))
  for _, v in ipairs(self.serialids) do
    os:marshalInt64(v)
  end
end
function GrcReceivedGiftInfos:unmarshal(os)
  self.gift_type = os:unmarshalInt32()
  self.receive_times = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.serialids, v)
  end
end
return GrcReceivedGiftInfos
