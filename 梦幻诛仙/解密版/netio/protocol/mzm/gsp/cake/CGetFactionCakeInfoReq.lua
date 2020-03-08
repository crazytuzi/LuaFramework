local CGetFactionCakeInfoReq = class("CGetFactionCakeInfoReq")
CGetFactionCakeInfoReq.TYPEID = 12627719
function CGetFactionCakeInfoReq:ctor(activityId, factionId)
  self.id = 12627719
  self.activityId = activityId or nil
  self.factionId = factionId or nil
end
function CGetFactionCakeInfoReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt64(self.factionId)
end
function CGetFactionCakeInfoReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.factionId = os:unmarshalInt64()
end
function CGetFactionCakeInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetFactionCakeInfoReq
