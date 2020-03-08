local SRecallMercenaryBrd = class("SRecallMercenaryBrd")
SRecallMercenaryBrd.TYPEID = 12598551
function SRecallMercenaryBrd:ctor(mercenary_factionid, mercenary_count)
  self.id = 12598551
  self.mercenary_factionid = mercenary_factionid or nil
  self.mercenary_count = mercenary_count or nil
end
function SRecallMercenaryBrd:marshal(os)
  os:marshalInt64(self.mercenary_factionid)
  os:marshalInt32(self.mercenary_count)
end
function SRecallMercenaryBrd:unmarshal(os)
  self.mercenary_factionid = os:unmarshalInt64()
  self.mercenary_count = os:unmarshalInt32()
end
function SRecallMercenaryBrd:sizepolicy(size)
  return size <= 65535
end
return SRecallMercenaryBrd
