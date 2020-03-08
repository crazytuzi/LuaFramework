local SSynJingjiSeasonEndtime = class("SSynJingjiSeasonEndtime")
SSynJingjiSeasonEndtime.TYPEID = 12595725
function SSynJingjiSeasonEndtime:ctor(seasonEndTime)
  self.id = 12595725
  self.seasonEndTime = seasonEndTime or nil
end
function SSynJingjiSeasonEndtime:marshal(os)
  os:marshalInt64(self.seasonEndTime)
end
function SSynJingjiSeasonEndtime:unmarshal(os)
  self.seasonEndTime = os:unmarshalInt64()
end
function SSynJingjiSeasonEndtime:sizepolicy(size)
  return size <= 65535
end
return SSynJingjiSeasonEndtime
