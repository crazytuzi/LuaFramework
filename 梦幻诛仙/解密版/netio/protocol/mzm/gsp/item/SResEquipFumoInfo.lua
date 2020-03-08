local SResEquipFumoInfo = class("SResEquipFumoInfo")
SResEquipFumoInfo.TYPEID = 12584717
function SResEquipFumoInfo:ctor(fumoInoList)
  self.id = 12584717
  self.fumoInoList = fumoInoList or {}
end
function SResEquipFumoInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.fumoInoList))
  for _, v in ipairs(self.fumoInoList) do
    v:marshal(os)
  end
end
function SResEquipFumoInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.EquipFumoInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.fumoInoList, v)
  end
end
function SResEquipFumoInfo:sizepolicy(size)
  return size <= 65535
end
return SResEquipFumoInfo
