local CGetRoleMFVRankReq = class("CGetRoleMFVRankReq")
CGetRoleMFVRankReq.TYPEID = 12586026
function CGetRoleMFVRankReq:ctor(fromNo, toNO)
  self.id = 12586026
  self.fromNo = fromNo or nil
  self.toNO = toNO or nil
end
function CGetRoleMFVRankReq:marshal(os)
  os:marshalInt32(self.fromNo)
  os:marshalInt32(self.toNO)
end
function CGetRoleMFVRankReq:unmarshal(os)
  self.fromNo = os:unmarshalInt32()
  self.toNO = os:unmarshalInt32()
end
function CGetRoleMFVRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleMFVRankReq
