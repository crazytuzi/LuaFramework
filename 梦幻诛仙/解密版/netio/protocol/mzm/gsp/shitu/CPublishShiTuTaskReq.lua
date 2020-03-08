local CPublishShiTuTaskReq = class("CPublishShiTuTaskReq")
CPublishShiTuTaskReq.TYPEID = 12601639
function CPublishShiTuTaskReq:ctor(role_id)
  self.id = 12601639
  self.role_id = role_id or nil
end
function CPublishShiTuTaskReq:marshal(os)
  os:marshalInt64(self.role_id)
end
function CPublishShiTuTaskReq:unmarshal(os)
  self.role_id = os:unmarshalInt64()
end
function CPublishShiTuTaskReq:sizepolicy(size)
  return size <= 65535
end
return CPublishShiTuTaskReq
