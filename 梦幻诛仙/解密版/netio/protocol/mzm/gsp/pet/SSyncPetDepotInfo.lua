local SSyncPetDepotInfo = class("SSyncPetDepotInfo")
SSyncPetDepotInfo.TYPEID = 12590623
function SSyncPetDepotInfo:ctor(depotSize, petList, expandCount)
  self.id = 12590623
  self.depotSize = depotSize or nil
  self.petList = petList or {}
  self.expandCount = expandCount or nil
end
function SSyncPetDepotInfo:marshal(os)
  os:marshalInt32(self.depotSize)
  os:marshalCompactUInt32(table.getn(self.petList))
  for _, v in ipairs(self.petList) do
    v:marshal(os)
  end
  os:marshalInt32(self.expandCount)
end
function SSyncPetDepotInfo:unmarshal(os)
  self.depotSize = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.pet.PetInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.petList, v)
  end
  self.expandCount = os:unmarshalInt32()
end
function SSyncPetDepotInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncPetDepotInfo
