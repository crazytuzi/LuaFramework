local SEquipTransferHunRes = class("SEquipTransferHunRes")
SEquipTransferHunRes.TYPEID = 12584751
function SEquipTransferHunRes:ctor(newExproList)
  self.id = 12584751
  self.newExproList = newExproList or {}
end
function SEquipTransferHunRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.newExproList))
  for _, v in ipairs(self.newExproList) do
    v:marshal(os)
  end
end
function SEquipTransferHunRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ExtraProBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.newExproList, v)
  end
end
function SEquipTransferHunRes:sizepolicy(size)
  return size <= 65535
end
return SEquipTransferHunRes
