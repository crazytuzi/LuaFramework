local SBuyFashionFailed = class("SBuyFashionFailed")
SBuyFashionFailed.TYPEID = 12609359
SBuyFashionFailed.ERROR_ITEM_NOT_ENOUGH = -1
function SBuyFashionFailed:ctor(fashion_cfgid, retcode)
  self.id = 12609359
  self.fashion_cfgid = fashion_cfgid or nil
  self.retcode = retcode or nil
end
function SBuyFashionFailed:marshal(os)
  os:marshalInt32(self.fashion_cfgid)
  os:marshalInt32(self.retcode)
end
function SBuyFashionFailed:unmarshal(os)
  self.fashion_cfgid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SBuyFashionFailed:sizepolicy(size)
  return size <= 65535
end
return SBuyFashionFailed
