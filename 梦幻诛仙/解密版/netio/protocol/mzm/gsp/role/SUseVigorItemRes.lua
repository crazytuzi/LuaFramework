local SUseVigorItemRes = class("SUseVigorItemRes")
SUseVigorItemRes.TYPEID = 12585992
function SUseVigorItemRes:ctor(addVigor)
  self.id = 12585992
  self.addVigor = addVigor or nil
end
function SUseVigorItemRes:marshal(os)
  os:marshalInt32(self.addVigor)
end
function SUseVigorItemRes:unmarshal(os)
  self.addVigor = os:unmarshalInt32()
end
function SUseVigorItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseVigorItemRes
