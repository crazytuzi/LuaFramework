local SSynEquiptipRes = class("SSynEquiptipRes")
SSynEquiptipRes.TYPEID = 12584838
function SSynEquiptipRes:ctor(state)
  self.id = 12584838
  self.state = state or nil
end
function SSynEquiptipRes:marshal(os)
  os:marshalInt32(self.state)
end
function SSynEquiptipRes:unmarshal(os)
  self.state = os:unmarshalInt32()
end
function SSynEquiptipRes:sizepolicy(size)
  return size <= 65535
end
return SSynEquiptipRes
