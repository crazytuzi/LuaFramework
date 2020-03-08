local CMarrigeParadeReq = class("CMarrigeParadeReq")
CMarrigeParadeReq.TYPEID = 12599839
function CMarrigeParadeReq:ctor(paradeCfgid)
  self.id = 12599839
  self.paradeCfgid = paradeCfgid or nil
end
function CMarrigeParadeReq:marshal(os)
  os:marshalInt32(self.paradeCfgid)
end
function CMarrigeParadeReq:unmarshal(os)
  self.paradeCfgid = os:unmarshalInt32()
end
function CMarrigeParadeReq:sizepolicy(size)
  return size <= 65535
end
return CMarrigeParadeReq
