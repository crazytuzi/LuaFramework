local CJewelTransferCountReq = class("CJewelTransferCountReq")
CJewelTransferCountReq.TYPEID = 12618784
function CJewelTransferCountReq:ctor()
  self.id = 12618784
end
function CJewelTransferCountReq:marshal(os)
end
function CJewelTransferCountReq:unmarshal(os)
end
function CJewelTransferCountReq:sizepolicy(size)
  return size <= 65535
end
return CJewelTransferCountReq
