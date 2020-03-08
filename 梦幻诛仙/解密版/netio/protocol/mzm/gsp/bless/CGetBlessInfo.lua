local CGetBlessInfo = class("CGetBlessInfo")
CGetBlessInfo.TYPEID = 12614660
function CGetBlessInfo:ctor(activity_cfgid)
  self.id = 12614660
  self.activity_cfgid = activity_cfgid or nil
end
function CGetBlessInfo:marshal(os)
  os:marshalInt32(self.activity_cfgid)
end
function CGetBlessInfo:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
end
function CGetBlessInfo:sizepolicy(size)
  return size <= 65535
end
return CGetBlessInfo
