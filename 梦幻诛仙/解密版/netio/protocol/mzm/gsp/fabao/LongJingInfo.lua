local OctetsStream = require("netio.OctetsStream")
local LongJingInfo = class("LongJingInfo")
LongJingInfo.LONG_JING_POS_1 = 1
LongJingInfo.LONG_JING_POS_2 = 2
LongJingInfo.LONG_JING_POS_3 = 3
function LongJingInfo:ctor(longjingItems)
  self.longjingItems = longjingItems or {}
end
function LongJingInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.longjingItems) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.longjingItems) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function LongJingInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.longjingItems[k] = v
  end
end
return LongJingInfo
