local SArenaTitle = class("SArenaTitle")
SArenaTitle.TYPEID = 12596752
function SArenaTitle:ctor(camp)
  self.id = 12596752
  self.camp = camp or nil
end
function SArenaTitle:marshal(os)
  os:marshalInt32(self.camp)
end
function SArenaTitle:unmarshal(os)
  self.camp = os:unmarshalInt32()
end
function SArenaTitle:sizepolicy(size)
  return size <= 65535
end
return SArenaTitle
