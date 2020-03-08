local SChangeDisPlayFabaoErrorRes = class("SChangeDisPlayFabaoErrorRes")
SChangeDisPlayFabaoErrorRes.TYPEID = 12596020
SChangeDisPlayFabaoErrorRes.ERROR_FA_BAO_NOT_EXIST = 1
function SChangeDisPlayFabaoErrorRes:ctor(errorCode)
  self.id = 12596020
  self.errorCode = errorCode or nil
end
function SChangeDisPlayFabaoErrorRes:marshal(os)
  os:marshalInt32(self.errorCode)
end
function SChangeDisPlayFabaoErrorRes:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
end
function SChangeDisPlayFabaoErrorRes:sizepolicy(size)
  return size <= 65535
end
return SChangeDisPlayFabaoErrorRes
