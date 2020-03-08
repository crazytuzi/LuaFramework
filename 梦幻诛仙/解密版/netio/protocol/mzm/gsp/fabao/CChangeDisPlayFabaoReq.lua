local CChangeDisPlayFabaoReq = class("CChangeDisPlayFabaoReq")
CChangeDisPlayFabaoReq.TYPEID = 12595995
function CChangeDisPlayFabaoReq:ctor(faobaotype)
  self.id = 12595995
  self.faobaotype = faobaotype or nil
end
function CChangeDisPlayFabaoReq:marshal(os)
  os:marshalInt32(self.faobaotype)
end
function CChangeDisPlayFabaoReq:unmarshal(os)
  self.faobaotype = os:unmarshalInt32()
end
function CChangeDisPlayFabaoReq:sizepolicy(size)
  return size <= 65535
end
return CChangeDisPlayFabaoReq
