local SPetSoulAddExpErrorRes = class("SPetSoulAddExpErrorRes")
SPetSoulAddExpErrorRes.TYPEID = 12590677
SPetSoulAddExpErrorRes.ERROR_ITEM_NOT_ENOUGH = 1
SPetSoulAddExpErrorRes.ERROR_NO_PROP = 2
SPetSoulAddExpErrorRes.ERROR_MAX_LEVEL = 3
SPetSoulAddExpErrorRes.ERROR_NOT_OVER_PET_LEVEL = 4
SPetSoulAddExpErrorRes.ERROR_ITEM_TYPE = 5
function SPetSoulAddExpErrorRes:ctor(ret)
  self.id = 12590677
  self.ret = ret or nil
end
function SPetSoulAddExpErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SPetSoulAddExpErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SPetSoulAddExpErrorRes:sizepolicy(size)
  return size <= 65535
end
return SPetSoulAddExpErrorRes
