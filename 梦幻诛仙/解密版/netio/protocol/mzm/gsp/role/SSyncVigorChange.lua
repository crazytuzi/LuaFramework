local SSyncVigorChange = class("SSyncVigorChange")
SSyncVigorChange.TYPEID = 12586005
function SSyncVigorChange:ctor(vigor)
  self.id = 12586005
  self.vigor = vigor or nil
end
function SSyncVigorChange:marshal(os)
  os:marshalInt32(self.vigor)
end
function SSyncVigorChange:unmarshal(os)
  self.vigor = os:unmarshalInt32()
end
function SSyncVigorChange:sizepolicy(size)
  return size <= 65535
end
return SSyncVigorChange
