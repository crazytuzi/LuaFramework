local OctetsStream = require("netio.OctetsStream")
local MallItemInfo = class("MallItemInfo")
function MallItemInfo:ctor(malltype, itemid2count)
  self.malltype = malltype or nil
  self.itemid2count = itemid2count or {}
end
function MallItemInfo:marshal(os)
  os:marshalInt32(self.malltype)
  local _size_ = 0
  for _, _ in pairs(self.itemid2count) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemid2count) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function MallItemInfo:unmarshal(os)
  self.malltype = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemid2count[k] = v
  end
end
return MallItemInfo
