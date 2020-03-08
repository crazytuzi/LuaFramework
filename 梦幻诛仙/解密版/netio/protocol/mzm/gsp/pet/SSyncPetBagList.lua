local SSyncPetBagList = class("SSyncPetBagList")
SSyncPetBagList.TYPEID = 12590593
function SSyncPetBagList:ctor(fightPetId, showPetId, petList, bagSize, expandCount)
  self.id = 12590593
  self.fightPetId = fightPetId or nil
  self.showPetId = showPetId or nil
  self.petList = petList or {}
  self.bagSize = bagSize or nil
  self.expandCount = expandCount or nil
end
function SSyncPetBagList:marshal(os)
  os:marshalInt64(self.fightPetId)
  os:marshalInt64(self.showPetId)
  os:marshalCompactUInt32(table.getn(self.petList))
  for _, v in ipairs(self.petList) do
    v:marshal(os)
  end
  os:marshalInt32(self.bagSize)
  os:marshalInt32(self.expandCount)
end
function SSyncPetBagList:unmarshal(os)
  self.fightPetId = os:unmarshalInt64()
  self.showPetId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.pet.PetInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.petList, v)
  end
  self.bagSize = os:unmarshalInt32()
  self.expandCount = os:unmarshalInt32()
end
function SSyncPetBagList:sizepolicy(size)
  return size <= 65535
end
return SSyncPetBagList
