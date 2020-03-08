local OctetsStream = require("netio.OctetsStream")
local DrawAwardInfo = class("DrawAwardInfo")
DrawAwardInfo.YUAN_BAO_BIG_AWARD = 1
DrawAwardInfo.CHEST_AWARD = 2
DrawAwardInfo.OTHER_AWARD = 4
function DrawAwardInfo:ctor(item_type, index, item_cfg_id2count)
  self.item_type = item_type or nil
  self.index = index or nil
  self.item_cfg_id2count = item_cfg_id2count or {}
end
function DrawAwardInfo:marshal(os)
  os:marshalInt32(self.item_type)
  os:marshalInt32(self.index)
  local _size_ = 0
  for _, _ in pairs(self.item_cfg_id2count) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.item_cfg_id2count) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function DrawAwardInfo:unmarshal(os)
  self.item_type = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.item_cfg_id2count[k] = v
  end
end
return DrawAwardInfo
