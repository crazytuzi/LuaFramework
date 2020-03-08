local CRefuseOrAgreeTeamInstanceReq = class("CRefuseOrAgreeTeamInstanceReq")
CRefuseOrAgreeTeamInstanceReq.TYPEID = 794881
CRefuseOrAgreeTeamInstanceReq.Agree = 1
CRefuseOrAgreeTeamInstanceReq.Deny = 2
function CRefuseOrAgreeTeamInstanceReq:ctor(operation)
  self.id = 794881
  self.operation = operation or nil
end
function CRefuseOrAgreeTeamInstanceReq:marshal(os)
  os:marshalInt32(self.operation)
end
function CRefuseOrAgreeTeamInstanceReq:unmarshal(os)
  self.operation = os:unmarshalInt32()
end
function CRefuseOrAgreeTeamInstanceReq:sizepolicy(size)
  return size <= 65535
end
return CRefuseOrAgreeTeamInstanceReq
