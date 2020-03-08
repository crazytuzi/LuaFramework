local SReplaceWingPropertyRes = class("SReplaceWingPropertyRes")
SReplaceWingPropertyRes.TYPEID = 12596495
function SReplaceWingPropertyRes:ctor(index, propertyList)
  self.id = 12596495
  self.index = index or nil
  self.propertyList = propertyList or {}
end
function SReplaceWingPropertyRes:marshal(os)
  os:marshalInt32(self.index)
  os:marshalCompactUInt32(table.getn(self.propertyList))
  for _, v in ipairs(self.propertyList) do
    v:marshal(os)
  end
end
function SReplaceWingPropertyRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.WingProperty")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.propertyList, v)
  end
end
function SReplaceWingPropertyRes:sizepolicy(size)
  return size <= 65535
end
return SReplaceWingPropertyRes
