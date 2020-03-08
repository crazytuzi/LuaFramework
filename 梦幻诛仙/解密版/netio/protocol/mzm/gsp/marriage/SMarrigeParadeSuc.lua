local SMarrigeParadeSuc = class("SMarrigeParadeSuc")
SMarrigeParadeSuc.TYPEID = 12599838
function SMarrigeParadeSuc:ctor(paradeCfgid)
  self.id = 12599838
  self.paradeCfgid = paradeCfgid or nil
end
function SMarrigeParadeSuc:marshal(os)
  os:marshalInt32(self.paradeCfgid)
end
function SMarrigeParadeSuc:unmarshal(os)
  self.paradeCfgid = os:unmarshalInt32()
end
function SMarrigeParadeSuc:sizepolicy(size)
  return size <= 65535
end
return SMarrigeParadeSuc
