local SSetDefaultSKillRes = class("SSetDefaultSKillRes")
SSetDefaultSKillRes.TYPEID = 12589577
function SSetDefaultSKillRes:ctor(skillBagId)
  self.id = 12589577
  self.skillBagId = skillBagId or nil
end
function SSetDefaultSKillRes:marshal(os)
  os:marshalInt32(self.skillBagId)
end
function SSetDefaultSKillRes:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
end
function SSetDefaultSKillRes:sizepolicy(size)
  return size <= 65535
end
return SSetDefaultSKillRes
