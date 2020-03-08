local FashionInfo = require("netio.protocol.mzm.gsp.children.FashionInfo")
local SRenewalFashionRsp = class("SRenewalFashionRsp")
SRenewalFashionRsp.TYPEID = 12609434
function SRenewalFashionRsp:ctor(fashionCfgId, fashionInfo)
  self.id = 12609434
  self.fashionCfgId = fashionCfgId or nil
  self.fashionInfo = fashionInfo or FashionInfo.new()
end
function SRenewalFashionRsp:marshal(os)
  os:marshalInt32(self.fashionCfgId)
  self.fashionInfo:marshal(os)
end
function SRenewalFashionRsp:unmarshal(os)
  self.fashionCfgId = os:unmarshalInt32()
  self.fashionInfo = FashionInfo.new()
  self.fashionInfo:unmarshal(os)
end
function SRenewalFashionRsp:sizepolicy(size)
  return size <= 65535
end
return SRenewalFashionRsp
