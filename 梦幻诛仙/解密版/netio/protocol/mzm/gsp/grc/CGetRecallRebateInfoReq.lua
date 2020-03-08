local CGetRecallRebateInfoReq = class("CGetRecallRebateInfoReq")
CGetRecallRebateInfoReq.TYPEID = 12600383
function CGetRecallRebateInfoReq:ctor()
  self.id = 12600383
end
function CGetRecallRebateInfoReq:marshal(os)
end
function CGetRecallRebateInfoReq:unmarshal(os)
end
function CGetRecallRebateInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetRecallRebateInfoReq
