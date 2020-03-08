local CGetRoleFightValueRankReq = class("CGetRoleFightValueRankReq")
CGetRoleFightValueRankReq.TYPEID = 12586022
function CGetRoleFightValueRankReq:ctor(fromNo, toNO)
  self.id = 12586022
  self.fromNo = fromNo or nil
  self.toNO = toNO or nil
end
function CGetRoleFightValueRankReq:marshal(os)
  os:marshalInt32(self.fromNo)
  os:marshalInt32(self.toNO)
end
function CGetRoleFightValueRankReq:unmarshal(os)
  self.fromNo = os:unmarshalInt32()
  self.toNO = os:unmarshalInt32()
end
function CGetRoleFightValueRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleFightValueRankReq
