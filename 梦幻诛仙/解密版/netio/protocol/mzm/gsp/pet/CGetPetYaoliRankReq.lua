local CGetPetYaoliRankReq = class("CGetPetYaoliRankReq")
CGetPetYaoliRankReq.TYPEID = 12590651
function CGetPetYaoliRankReq:ctor(fromNo, toNO)
  self.id = 12590651
  self.fromNo = fromNo or nil
  self.toNO = toNO or nil
end
function CGetPetYaoliRankReq:marshal(os)
  os:marshalInt32(self.fromNo)
  os:marshalInt32(self.toNO)
end
function CGetPetYaoliRankReq:unmarshal(os)
  self.fromNo = os:unmarshalInt32()
  self.toNO = os:unmarshalInt32()
end
function CGetPetYaoliRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetPetYaoliRankReq
