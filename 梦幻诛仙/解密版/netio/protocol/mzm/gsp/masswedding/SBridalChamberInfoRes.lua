local SBridalChamberInfoRes = class("SBridalChamberInfoRes")
SBridalChamberInfoRes.TYPEID = 12604944
function SBridalChamberInfoRes:ctor(roleid, groom, bride)
  self.id = 12604944
  self.roleid = roleid or nil
  self.groom = groom or nil
  self.bride = bride or nil
end
function SBridalChamberInfoRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.groom)
  os:marshalInt32(self.bride)
end
function SBridalChamberInfoRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.groom = os:unmarshalInt32()
  self.bride = os:unmarshalInt32()
end
function SBridalChamberInfoRes:sizepolicy(size)
  return size <= 65535
end
return SBridalChamberInfoRes
