local OctetsStream = require("netio.OctetsStream")
local BagInfo = class("BagInfo")
BagInfo.BAG = 340600000
BagInfo.EQUIPBAG = 340600001
BagInfo.SUPER_EQUIPMENT_JEWEL_BAG = 340600005
BagInfo.FABAO_BAG = 340600006
BagInfo.CHANGE_MODEL_CARD_BAG = 340600007
BagInfo.TREASURE_BAG = 340600008
BagInfo.PET_MARK_BAG = 340600009
function BagInfo:ctor(name, capacity, items)
  self.name = name or nil
  self.capacity = capacity or nil
  self.items = items or {}
end
function BagInfo:marshal(os)
  os:marshalString(self.name)
  os:marshalInt32(self.capacity)
  local _size_ = 0
  for _, _ in pairs(self.items) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.items) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function BagInfo:unmarshal(os)
  self.name = os:unmarshalString()
  self.capacity = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.items[k] = v
  end
end
return BagInfo
