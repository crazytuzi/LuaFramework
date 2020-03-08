local CCheckCakeHistoryReq = class("CCheckCakeHistoryReq")
CCheckCakeHistoryReq.TYPEID = 12627721
function CCheckCakeHistoryReq:ctor(activityId, factionId, roleId)
  self.id = 12627721
  self.activityId = activityId or nil
  self.factionId = factionId or nil
  self.roleId = roleId or nil
end
function CCheckCakeHistoryReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt64(self.factionId)
  os:marshalInt64(self.roleId)
end
function CCheckCakeHistoryReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.factionId = os:unmarshalInt64()
  self.roleId = os:unmarshalInt64()
end
function CCheckCakeHistoryReq:sizepolicy(size)
  return size <= 65535
end
return CCheckCakeHistoryReq
