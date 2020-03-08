local SyncPointRacePromotion = class("SyncPointRacePromotion")
SyncPointRacePromotion.TYPEID = 12617051
function SyncPointRacePromotion:ctor(activity_cfgid, zone, promotions)
  self.id = 12617051
  self.activity_cfgid = activity_cfgid or nil
  self.zone = zone or nil
  self.promotions = promotions or {}
end
function SyncPointRacePromotion:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.zone)
  os:marshalCompactUInt32(table.getn(self.promotions))
  for _, v in ipairs(self.promotions) do
    os:marshalOctets(v)
  end
end
function SyncPointRacePromotion:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.zone = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.promotions, v)
  end
end
function SyncPointRacePromotion:sizepolicy(size)
  return size <= 65535
end
return SyncPointRacePromotion
