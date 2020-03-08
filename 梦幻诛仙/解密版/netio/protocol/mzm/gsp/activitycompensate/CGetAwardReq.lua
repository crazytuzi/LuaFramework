local CGetAwardReq = class("CGetAwardReq")
CGetAwardReq.TYPEID = 12627459
CGetAwardReq.GET_TYPE_FREE = 0
CGetAwardReq.GET_TYPE_GOLD = 1
CGetAwardReq.GET_TYPE_YUANBAO = 2
CGetAwardReq.USE_DOUBLE_POINT_NO = 0
CGetAwardReq.USE_DOUBLE_POINT_YES = 1
function CGetAwardReq:ctor(activityid, get_type, left_times, use_double_point)
  self.id = 12627459
  self.activityid = activityid or nil
  self.get_type = get_type or nil
  self.left_times = left_times or nil
  self.use_double_point = use_double_point or nil
end
function CGetAwardReq:marshal(os)
  os:marshalInt32(self.activityid)
  os:marshalInt32(self.get_type)
  os:marshalInt32(self.left_times)
  os:marshalInt32(self.use_double_point)
end
function CGetAwardReq:unmarshal(os)
  self.activityid = os:unmarshalInt32()
  self.get_type = os:unmarshalInt32()
  self.left_times = os:unmarshalInt32()
  self.use_double_point = os:unmarshalInt32()
end
function CGetAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetAwardReq
