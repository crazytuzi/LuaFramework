local KeepAlive = class("KeepAlive")
KeepAlive.TYPEID = 100
function KeepAlive:ctor(code)
  self.id = 100
  self.code = code or nil
end
function KeepAlive:marshal(os)
  os:marshalInt32(self.code)
end
function KeepAlive:unmarshal(os)
  self.code = os:unmarshalInt32()
end
function KeepAlive:sizepolicy(size)
  return size <= 16
end
return KeepAlive
