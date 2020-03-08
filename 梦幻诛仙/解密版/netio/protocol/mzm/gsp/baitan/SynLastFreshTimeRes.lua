local SynLastFreshTimeRes = class("SynLastFreshTimeRes")
SynLastFreshTimeRes.TYPEID = 12584996
function SynLastFreshTimeRes:ctor(lastFreshTime)
  self.id = 12584996
  self.lastFreshTime = lastFreshTime or nil
end
function SynLastFreshTimeRes:marshal(os)
  os:marshalInt64(self.lastFreshTime)
end
function SynLastFreshTimeRes:unmarshal(os)
  self.lastFreshTime = os:unmarshalInt64()
end
function SynLastFreshTimeRes:sizepolicy(size)
  return size <= 65535
end
return SynLastFreshTimeRes
