local CGetRoleLevelRankReq = class("CGetRoleLevelRankReq")
CGetRoleLevelRankReq.TYPEID = 12586019
function CGetRoleLevelRankReq:ctor(fromNo, toNO)
  self.id = 12586019
  self.fromNo = fromNo or nil
  self.toNO = toNO or nil
end
function CGetRoleLevelRankReq:marshal(os)
  os:marshalInt32(self.fromNo)
  os:marshalInt32(self.toNO)
end
function CGetRoleLevelRankReq:unmarshal(os)
  self.fromNo = os:unmarshalInt32()
  self.toNO = os:unmarshalInt32()
end
function CGetRoleLevelRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleLevelRankReq
