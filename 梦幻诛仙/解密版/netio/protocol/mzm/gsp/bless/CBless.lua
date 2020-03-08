local CBless = class("CBless")
CBless.TYPEID = 12614661
function CBless:ctor(activity_cfgid)
  self.id = 12614661
  self.activity_cfgid = activity_cfgid or nil
end
function CBless:marshal(os)
  os:marshalInt32(self.activity_cfgid)
end
function CBless:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
end
function CBless:sizepolicy(size)
  return size <= 65535
end
return CBless
