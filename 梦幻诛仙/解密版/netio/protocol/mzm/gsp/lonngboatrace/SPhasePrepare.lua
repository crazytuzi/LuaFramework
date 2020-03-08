local SPhasePrepare = class("SPhasePrepare")
SPhasePrepare.TYPEID = 12619266
function SPhasePrepare:ctor(phaseId, endTimeStamp, currTimeStamp)
  self.id = 12619266
  self.phaseId = phaseId or nil
  self.endTimeStamp = endTimeStamp or nil
  self.currTimeStamp = currTimeStamp or nil
end
function SPhasePrepare:marshal(os)
  os:marshalInt32(self.phaseId)
  os:marshalInt64(self.endTimeStamp)
  os:marshalInt64(self.currTimeStamp)
end
function SPhasePrepare:unmarshal(os)
  self.phaseId = os:unmarshalInt32()
  self.endTimeStamp = os:unmarshalInt64()
  self.currTimeStamp = os:unmarshalInt64()
end
function SPhasePrepare:sizepolicy(size)
  return size <= 65535
end
return SPhasePrepare
