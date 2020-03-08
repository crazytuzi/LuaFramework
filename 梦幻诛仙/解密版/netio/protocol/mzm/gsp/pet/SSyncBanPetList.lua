local SSyncBanPetList = class("SSyncBanPetList")
SSyncBanPetList.TYPEID = 12590660
function SSyncBanPetList:ctor(banPetList)
  self.id = 12590660
  self.banPetList = banPetList or {}
end
function SSyncBanPetList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.banPetList))
  for _, v in ipairs(self.banPetList) do
    os:marshalInt32(v)
  end
end
function SSyncBanPetList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.banPetList, v)
  end
end
function SSyncBanPetList:sizepolicy(size)
  return size <= 65535
end
return SSyncBanPetList
