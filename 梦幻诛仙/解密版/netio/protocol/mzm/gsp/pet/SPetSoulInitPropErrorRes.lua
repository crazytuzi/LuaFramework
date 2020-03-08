local SPetSoulInitPropErrorRes = class("SPetSoulInitPropErrorRes")
SPetSoulInitPropErrorRes.TYPEID = 12590676
SPetSoulInitPropErrorRes.ERROR_NO_PROP = 1
function SPetSoulInitPropErrorRes:ctor(ret)
  self.id = 12590676
  self.ret = ret or nil
end
function SPetSoulInitPropErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SPetSoulInitPropErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SPetSoulInitPropErrorRes:sizepolicy(size)
  return size <= 65535
end
return SPetSoulInitPropErrorRes
