local CRemoveNewOccPlanTipReq = class("CRemoveNewOccPlanTipReq")
CRemoveNewOccPlanTipReq.TYPEID = 12596551
function CRemoveNewOccPlanTipReq:ctor()
  self.id = 12596551
end
function CRemoveNewOccPlanTipReq:marshal(os)
end
function CRemoveNewOccPlanTipReq:unmarshal(os)
end
function CRemoveNewOccPlanTipReq:sizepolicy(size)
  return size <= 65535
end
return CRemoveNewOccPlanTipReq
