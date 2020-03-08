local SRoleClothesListRes = class("SRoleClothesListRes")
SRoleClothesListRes.TYPEID = 12597250
function SRoleClothesListRes:ctor(curid, maxcount, clothesList)
  self.id = 12597250
  self.curid = curid or nil
  self.maxcount = maxcount or nil
  self.clothesList = clothesList or {}
end
function SRoleClothesListRes:marshal(os)
  os:marshalInt32(self.curid)
  os:marshalInt32(self.maxcount)
  os:marshalCompactUInt32(table.getn(self.clothesList))
  for _, v in ipairs(self.clothesList) do
    v:marshal(os)
  end
end
function SRoleClothesListRes:unmarshal(os)
  self.curid = os:unmarshalInt32()
  self.maxcount = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.roledye.ColorIds")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.clothesList, v)
  end
end
function SRoleClothesListRes:sizepolicy(size)
  return size <= 65535
end
return SRoleClothesListRes
