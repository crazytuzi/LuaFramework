local CGetAllAwardReq = class("CGetAllAwardReq")
CGetAllAwardReq.TYPEID = 12627458
CGetAllAwardReq.GET_TYPE_FREE = 0
CGetAllAwardReq.GET_TYPE_GOLD = 1
CGetAllAwardReq.GET_TYPE_YUANBAO = 2
CGetAllAwardReq.USE_DOUBLE_POINT_NO = 0
CGetAllAwardReq.USE_DOUBLE_POINT_YES = 1
function CGetAllAwardReq:ctor(get_type, use_double_point)
  self.id = 12627458
  self.get_type = get_type or nil
  self.use_double_point = use_double_point or nil
end
function CGetAllAwardReq:marshal(os)
  os:marshalInt32(self.get_type)
  os:marshalInt32(self.use_double_point)
end
function CGetAllAwardReq:unmarshal(os)
  self.get_type = os:unmarshalInt32()
  self.use_double_point = os:unmarshalInt32()
end
function CGetAllAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetAllAwardReq
