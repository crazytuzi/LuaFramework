local SSyncFactionPkScoreBrd = class("SSyncFactionPkScoreBrd")
SSyncFactionPkScoreBrd.TYPEID = 12616718
function SSyncFactionPkScoreBrd:ctor(factionid, pk_score)
  self.id = 12616718
  self.factionid = factionid or nil
  self.pk_score = pk_score or nil
end
function SSyncFactionPkScoreBrd:marshal(os)
  os:marshalInt64(self.factionid)
  os:marshalInt32(self.pk_score)
end
function SSyncFactionPkScoreBrd:unmarshal(os)
  self.factionid = os:unmarshalInt64()
  self.pk_score = os:unmarshalInt32()
end
function SSyncFactionPkScoreBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncFactionPkScoreBrd
