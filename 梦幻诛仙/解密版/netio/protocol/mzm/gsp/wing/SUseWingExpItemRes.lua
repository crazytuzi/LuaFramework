local SUseWingExpItemRes = class("SUseWingExpItemRes")
SUseWingExpItemRes.TYPEID = 12596492
function SUseWingExpItemRes:ctor(index, propertyList, exp, oldLevel, newLevel, addExp)
  self.id = 12596492
  self.index = index or nil
  self.propertyList = propertyList or {}
  self.exp = exp or nil
  self.oldLevel = oldLevel or nil
  self.newLevel = newLevel or nil
  self.addExp = addExp or nil
end
function SUseWingExpItemRes:marshal(os)
  os:marshalInt32(self.index)
  os:marshalCompactUInt32(table.getn(self.propertyList))
  for _, v in ipairs(self.propertyList) do
    v:marshal(os)
  end
  os:marshalInt32(self.exp)
  os:marshalInt32(self.oldLevel)
  os:marshalInt32(self.newLevel)
  os:marshalInt32(self.addExp)
end
function SUseWingExpItemRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.WingProperty")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.propertyList, v)
  end
  self.exp = os:unmarshalInt32()
  self.oldLevel = os:unmarshalInt32()
  self.newLevel = os:unmarshalInt32()
  self.addExp = os:unmarshalInt32()
end
function SUseWingExpItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseWingExpItemRes
