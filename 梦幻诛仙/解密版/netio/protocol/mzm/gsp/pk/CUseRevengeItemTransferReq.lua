local CUseRevengeItemTransferReq = class("CUseRevengeItemTransferReq")
CUseRevengeItemTransferReq.TYPEID = 12619796
function CUseRevengeItemTransferReq:ctor()
  self.id = 12619796
end
function CUseRevengeItemTransferReq:marshal(os)
end
function CUseRevengeItemTransferReq:unmarshal(os)
end
function CUseRevengeItemTransferReq:sizepolicy(size)
  return size <= 65535
end
return CUseRevengeItemTransferReq
