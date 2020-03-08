local SBridalChamberRes = class("SBridalChamberRes")
SBridalChamberRes.TYPEID = 12604954
function SBridalChamberRes:ctor(roleid)
  self.id = 12604954
  self.roleid = roleid or nil
end
function SBridalChamberRes:marshal(os)
  os:marshalInt64(self.roleid)
end
function SBridalChamberRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function SBridalChamberRes:sizepolicy(size)
  return size <= 65535
end
return SBridalChamberRes
