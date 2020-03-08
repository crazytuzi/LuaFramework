local SServerShutDownBrd = class("SServerShutDownBrd")
SServerShutDownBrd.TYPEID = 12582914
function SServerShutDownBrd:ctor(delay)
  self.id = 12582914
  self.delay = delay or nil
end
function SServerShutDownBrd:marshal(os)
  os:marshalInt32(self.delay)
end
function SServerShutDownBrd:unmarshal(os)
  self.delay = os:unmarshalInt32()
end
function SServerShutDownBrd:sizepolicy(size)
  return size <= 65535
end
return SServerShutDownBrd
