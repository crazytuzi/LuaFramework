local SRestWingPropertyRes = class("SRestWingPropertyRes")
SRestWingPropertyRes.TYPEID = 12596499
function SRestWingPropertyRes:ctor(index, propertyList)
  self.id = 12596499
  self.index = index or nil
  self.propertyList = propertyList or {}
end
function SRestWingPropertyRes:marshal(os)
  os:marshalInt32(self.index)
  os:marshalCompactUInt32(table.getn(self.propertyList))
  for _, v in ipairs(self.propertyList) do
    v:marshal(os)
  end
end
function SRestWingPropertyRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.WingProperty")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.propertyList, v)
  end
end
function SRestWingPropertyRes:sizepolicy(size)
  return size <= 65535
end
return SRestWingPropertyRes
