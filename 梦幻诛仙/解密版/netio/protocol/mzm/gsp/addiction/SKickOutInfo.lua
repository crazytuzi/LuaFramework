local SKickOutInfo = class("SKickOutInfo")
SKickOutInfo.TYPEID = 12608005
SKickOutInfo.ONLINE_TIME = 1
SKickOutInfo.TOTAL_ONLINE_TIME = 2
SKickOutInfo.SPILL_ONLINE_TIME = 3
function SKickOutInfo:ctor(reason, identity, kickout_type, total_online_time, online_time, rest_time)
  self.id = 12608005
  self.reason = reason or nil
  self.identity = identity or nil
  self.kickout_type = kickout_type or nil
  self.total_online_time = total_online_time or nil
  self.online_time = online_time or nil
  self.rest_time = rest_time or nil
end
function SKickOutInfo:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.identity)
  os:marshalInt32(self.kickout_type)
  os:marshalInt32(self.total_online_time)
  os:marshalInt32(self.online_time)
  os:marshalInt32(self.rest_time)
end
function SKickOutInfo:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.identity = os:unmarshalInt32()
  self.kickout_type = os:unmarshalInt32()
  self.total_online_time = os:unmarshalInt32()
  self.online_time = os:unmarshalInt32()
  self.rest_time = os:unmarshalInt32()
end
function SKickOutInfo:sizepolicy(size)
  return size <= 65535
end
return SKickOutInfo
