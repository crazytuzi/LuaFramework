local CRefreshAlternativeBuffCfgidsReq = class("CRefreshAlternativeBuffCfgidsReq")
CRefreshAlternativeBuffCfgidsReq.TYPEID = 12612870
function CRefreshAlternativeBuffCfgidsReq:ctor()
  self.id = 12612870
end
function CRefreshAlternativeBuffCfgidsReq:marshal(os)
end
function CRefreshAlternativeBuffCfgidsReq:unmarshal(os)
end
function CRefreshAlternativeBuffCfgidsReq:sizepolicy(size)
  return size <= 65535
end
return CRefreshAlternativeBuffCfgidsReq
