local SRaceStatusRes = class("SRaceStatusRes")
SRaceStatusRes.TYPEID = 12602122
function SRaceStatusRes:ctor(statuscode, beginTime, curCount, maxCount)
  self.id = 12602122
  self.statuscode = statuscode or nil
  self.beginTime = beginTime or nil
  self.curCount = curCount or nil
  self.maxCount = maxCount or nil
end
function SRaceStatusRes:marshal(os)
  os:marshalInt32(self.statuscode)
  os:marshalInt32(self.beginTime)
  os:marshalInt32(self.curCount)
  os:marshalInt32(self.maxCount)
end
function SRaceStatusRes:unmarshal(os)
  self.statuscode = os:unmarshalInt32()
  self.beginTime = os:unmarshalInt32()
  self.curCount = os:unmarshalInt32()
  self.maxCount = os:unmarshalInt32()
end
function SRaceStatusRes:sizepolicy(size)
  return size <= 65535
end
return SRaceStatusRes
