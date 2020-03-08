local SCheckXItemInfoRep = class("SCheckXItemInfoRep")
SCheckXItemInfoRep.TYPEID = 12584457
function SCheckXItemInfoRep:ctor(roleIdChecked, itemInfos, itemIndex)
  self.id = 12584457
  self.roleIdChecked = roleIdChecked or nil
  self.itemInfos = itemInfos or {}
  self.itemIndex = itemIndex or nil
end
function SCheckXItemInfoRep:marshal(os)
  os:marshalInt64(self.roleIdChecked)
  do
    local _size_ = 0
    for _, _ in pairs(self.itemInfos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.itemInfos) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.itemIndex)
end
function SCheckXItemInfoRep:unmarshal(os)
  self.roleIdChecked = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.huanhun.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.itemInfos[k] = v
  end
  self.itemIndex = os:unmarshalInt32()
end
function SCheckXItemInfoRep:sizepolicy(size)
  return size <= 65535
end
return SCheckXItemInfoRep
