local CGetLoginSignActivityInfo = class("CGetLoginSignActivityInfo")
CGetLoginSignActivityInfo.TYPEID = 12604685
function CGetLoginSignActivityInfo:ctor()
  self.id = 12604685
end
function CGetLoginSignActivityInfo:marshal(os)
end
function CGetLoginSignActivityInfo:unmarshal(os)
end
function CGetLoginSignActivityInfo:sizepolicy(size)
  return size <= 65535
end
return CGetLoginSignActivityInfo
