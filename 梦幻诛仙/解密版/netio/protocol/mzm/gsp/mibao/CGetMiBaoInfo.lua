local CGetMiBaoInfo = class("CGetMiBaoInfo")
CGetMiBaoInfo.TYPEID = 12603399
function CGetMiBaoInfo:ctor()
  self.id = 12603399
end
function CGetMiBaoInfo:marshal(os)
end
function CGetMiBaoInfo:unmarshal(os)
end
function CGetMiBaoInfo:sizepolicy(size)
  return size <= 65535
end
return CGetMiBaoInfo
