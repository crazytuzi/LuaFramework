local OctetsStream = require("netio.OctetsStream")
local InnerInfo = class("InnerInfo")
function InnerInfo:ctor(ticketCount, hitIndexes)
  self.ticketCount = ticketCount or nil
  self.hitIndexes = hitIndexes or {}
end
function InnerInfo:marshal(os)
  os:marshalInt32(self.ticketCount)
  os:marshalCompactUInt32(table.getn(self.hitIndexes))
  for _, v in ipairs(self.hitIndexes) do
    os:marshalInt32(v)
  end
end
function InnerInfo:unmarshal(os)
  self.ticketCount = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.hitIndexes, v)
  end
end
return InnerInfo
