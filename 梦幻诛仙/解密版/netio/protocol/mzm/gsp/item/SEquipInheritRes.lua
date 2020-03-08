local SEquipInheritRes = class("SEquipInheritRes")
SEquipInheritRes.TYPEID = 12584746
function SEquipInheritRes:ctor(strengthLevel, isInheritHun, newExproList)
  self.id = 12584746
  self.strengthLevel = strengthLevel or nil
  self.isInheritHun = isInheritHun or nil
  self.newExproList = newExproList or {}
end
function SEquipInheritRes:marshal(os)
  os:marshalInt32(self.strengthLevel)
  os:marshalInt32(self.isInheritHun)
  os:marshalCompactUInt32(table.getn(self.newExproList))
  for _, v in ipairs(self.newExproList) do
    v:marshal(os)
  end
end
function SEquipInheritRes:unmarshal(os)
  self.strengthLevel = os:unmarshalInt32()
  self.isInheritHun = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ExtraProBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.newExproList, v)
  end
end
function SEquipInheritRes:sizepolicy(size)
  return size <= 65535
end
return SEquipInheritRes
