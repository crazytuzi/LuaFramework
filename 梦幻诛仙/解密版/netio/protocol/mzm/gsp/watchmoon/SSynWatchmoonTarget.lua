local SSynWatchmoonTarget = class("SSynWatchmoonTarget")
SSynWatchmoonTarget.TYPEID = 12600848
function SSynWatchmoonTarget:ctor(partnerroleid, endTime)
  self.id = 12600848
  self.partnerroleid = partnerroleid or nil
  self.endTime = endTime or nil
end
function SSynWatchmoonTarget:marshal(os)
  os:marshalInt64(self.partnerroleid)
  os:marshalInt64(self.endTime)
end
function SSynWatchmoonTarget:unmarshal(os)
  self.partnerroleid = os:unmarshalInt64()
  self.endTime = os:unmarshalInt64()
end
function SSynWatchmoonTarget:sizepolicy(size)
  return size <= 65535
end
return SSynWatchmoonTarget
