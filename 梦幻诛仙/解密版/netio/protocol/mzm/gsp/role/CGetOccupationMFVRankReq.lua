local CGetOccupationMFVRankReq = class("CGetOccupationMFVRankReq")
CGetOccupationMFVRankReq.TYPEID = 12586029
function CGetOccupationMFVRankReq:ctor(occupationId, fromNo, toNO)
  self.id = 12586029
  self.occupationId = occupationId or nil
  self.fromNo = fromNo or nil
  self.toNO = toNO or nil
end
function CGetOccupationMFVRankReq:marshal(os)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.fromNo)
  os:marshalInt32(self.toNO)
end
function CGetOccupationMFVRankReq:unmarshal(os)
  self.occupationId = os:unmarshalInt32()
  self.fromNo = os:unmarshalInt32()
  self.toNO = os:unmarshalInt32()
end
function CGetOccupationMFVRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetOccupationMFVRankReq
