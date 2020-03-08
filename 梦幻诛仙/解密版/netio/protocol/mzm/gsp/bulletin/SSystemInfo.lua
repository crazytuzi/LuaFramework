local SSystemInfo = class("SSystemInfo")
SSystemInfo.TYPEID = 12586498
function SSystemInfo:ctor(info)
  self.id = 12586498
  self.info = info or nil
end
function SSystemInfo:marshal(os)
  os:marshalString(self.info)
end
function SSystemInfo:unmarshal(os)
  self.info = os:unmarshalString()
end
function SSystemInfo:sizepolicy(size)
  return size <= 65535
end
return SSystemInfo
