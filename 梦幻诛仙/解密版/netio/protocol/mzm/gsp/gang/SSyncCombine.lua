local CombineGang = require("netio.protocol.mzm.gsp.gang.CombineGang")
local SSyncCombine = class("SSyncCombine")
SSyncCombine.TYPEID = 12589980
function SSyncCombine:ctor(target_gang, timestamp, applicants)
  self.id = 12589980
  self.target_gang = target_gang or CombineGang.new()
  self.timestamp = timestamp or nil
  self.applicants = applicants or {}
end
function SSyncCombine:marshal(os)
  self.target_gang:marshal(os)
  os:marshalInt64(self.timestamp)
  os:marshalCompactUInt32(table.getn(self.applicants))
  for _, v in ipairs(self.applicants) do
    os:marshalInt64(v)
  end
end
function SSyncCombine:unmarshal(os)
  self.target_gang = CombineGang.new()
  self.target_gang:unmarshal(os)
  self.timestamp = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.applicants, v)
  end
end
function SSyncCombine:sizepolicy(size)
  return size <= 65535
end
return SSyncCombine
