local SWatchmoonSuccessRes = class("SWatchmoonSuccessRes")
SWatchmoonSuccessRes.TYPEID = 12600833
function SWatchmoonSuccessRes:ctor(partnerRoleid, partnerName, activitycount)
  self.id = 12600833
  self.partnerRoleid = partnerRoleid or nil
  self.partnerName = partnerName or nil
  self.activitycount = activitycount or nil
end
function SWatchmoonSuccessRes:marshal(os)
  os:marshalInt64(self.partnerRoleid)
  os:marshalString(self.partnerName)
  os:marshalInt32(self.activitycount)
end
function SWatchmoonSuccessRes:unmarshal(os)
  self.partnerRoleid = os:unmarshalInt64()
  self.partnerName = os:unmarshalString()
  self.activitycount = os:unmarshalInt32()
end
function SWatchmoonSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SWatchmoonSuccessRes
