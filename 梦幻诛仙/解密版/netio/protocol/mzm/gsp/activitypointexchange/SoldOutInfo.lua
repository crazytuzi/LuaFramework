local OctetsStream = require("netio.OctetsStream")
local SoldOutInfo = class("SoldOutInfo")
function SoldOutInfo:ctor(goodsCfgIds)
  self.goodsCfgIds = goodsCfgIds or {}
end
function SoldOutInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.goodsCfgIds))
  for _, v in ipairs(self.goodsCfgIds) do
    os:marshalInt32(v)
  end
end
function SoldOutInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.goodsCfgIds, v)
  end
end
return SoldOutInfo
