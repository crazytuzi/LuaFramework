local SPetSoulRandomPropErrorRes = class("SPetSoulRandomPropErrorRes")
SPetSoulRandomPropErrorRes.TYPEID = 12590675
SPetSoulRandomPropErrorRes.ERROR_ITEM_NOT_ENOUGH = 1
SPetSoulRandomPropErrorRes.ERROR_MONEY_NOT_ENOUGH = 2
SPetSoulRandomPropErrorRes.ERROR_DO_DO_NOT_HAS_OTHER_PROP = 3
function SPetSoulRandomPropErrorRes:ctor(ret)
  self.id = 12590675
  self.ret = ret or nil
end
function SPetSoulRandomPropErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SPetSoulRandomPropErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SPetSoulRandomPropErrorRes:sizepolicy(size)
  return size <= 65535
end
return SPetSoulRandomPropErrorRes
