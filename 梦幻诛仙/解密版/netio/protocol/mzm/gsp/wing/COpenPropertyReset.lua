local COpenPropertyReset = class("COpenPropertyReset")
COpenPropertyReset.TYPEID = 12596502
function COpenPropertyReset:ctor(index)
  self.id = 12596502
  self.index = index or nil
end
function COpenPropertyReset:marshal(os)
  os:marshalInt32(self.index)
end
function COpenPropertyReset:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function COpenPropertyReset:sizepolicy(size)
  return size <= 65535
end
return COpenPropertyReset
