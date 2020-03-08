local FashionInfo = require("netio.protocol.mzm.gsp.children.FashionInfo")
local SBuyFashionSuccess = class("SBuyFashionSuccess")
SBuyFashionSuccess.TYPEID = 12609355
function SBuyFashionSuccess:ctor(fashion_cfgid, fashion_info)
  self.id = 12609355
  self.fashion_cfgid = fashion_cfgid or nil
  self.fashion_info = fashion_info or FashionInfo.new()
end
function SBuyFashionSuccess:marshal(os)
  os:marshalInt32(self.fashion_cfgid)
  self.fashion_info:marshal(os)
end
function SBuyFashionSuccess:unmarshal(os)
  self.fashion_cfgid = os:unmarshalInt32()
  self.fashion_info = FashionInfo.new()
  self.fashion_info:unmarshal(os)
end
function SBuyFashionSuccess:sizepolicy(size)
  return size <= 65535
end
return SBuyFashionSuccess
