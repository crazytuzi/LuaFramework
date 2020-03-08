local CGetRecallRebateReq = class("CGetRecallRebateReq")
CGetRecallRebateReq.TYPEID = 12600384
function CGetRecallRebateReq:ctor(num)
  self.id = 12600384
  self.num = num or nil
end
function CGetRecallRebateReq:marshal(os)
  os:marshalInt32(self.num)
end
function CGetRecallRebateReq:unmarshal(os)
  self.num = os:unmarshalInt32()
end
function CGetRecallRebateReq:sizepolicy(size)
  return size <= 65535
end
return CGetRecallRebateReq
