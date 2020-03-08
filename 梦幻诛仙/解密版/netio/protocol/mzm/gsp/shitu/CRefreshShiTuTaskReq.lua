local CRefreshShiTuTaskReq = class("CRefreshShiTuTaskReq")
CRefreshShiTuTaskReq.TYPEID = 12601633
function CRefreshShiTuTaskReq:ctor(role_id)
  self.id = 12601633
  self.role_id = role_id or nil
end
function CRefreshShiTuTaskReq:marshal(os)
  os:marshalInt64(self.role_id)
end
function CRefreshShiTuTaskReq:unmarshal(os)
  self.role_id = os:unmarshalInt64()
end
function CRefreshShiTuTaskReq:sizepolicy(size)
  return size <= 65535
end
return CRefreshShiTuTaskReq
