local SSyncMercenaryScoreBrd = class("SSyncMercenaryScoreBrd")
SSyncMercenaryScoreBrd.TYPEID = 12598552
function SSyncMercenaryScoreBrd:ctor(mercenary_factionid, mercenary_score)
  self.id = 12598552
  self.mercenary_factionid = mercenary_factionid or nil
  self.mercenary_score = mercenary_score or nil
end
function SSyncMercenaryScoreBrd:marshal(os)
  os:marshalInt64(self.mercenary_factionid)
  os:marshalInt32(self.mercenary_score)
end
function SSyncMercenaryScoreBrd:unmarshal(os)
  self.mercenary_factionid = os:unmarshalInt64()
  self.mercenary_score = os:unmarshalInt32()
end
function SSyncMercenaryScoreBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncMercenaryScoreBrd
