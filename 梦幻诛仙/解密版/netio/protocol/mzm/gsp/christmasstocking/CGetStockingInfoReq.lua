local CGetStockingInfoReq = class("CGetStockingInfoReq")
CGetStockingInfoReq.TYPEID = 12629514
function CGetStockingInfoReq:ctor(target_role_id)
  self.id = 12629514
  self.target_role_id = target_role_id or nil
end
function CGetStockingInfoReq:marshal(os)
  os:marshalInt64(self.target_role_id)
end
function CGetStockingInfoReq:unmarshal(os)
  self.target_role_id = os:unmarshalInt64()
end
function CGetStockingInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetStockingInfoReq
