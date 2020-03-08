local CGetLoginSumActivityInfos = class("CGetLoginSumActivityInfos")
CGetLoginSumActivityInfos.TYPEID = 12604681
function CGetLoginSumActivityInfos:ctor()
  self.id = 12604681
end
function CGetLoginSumActivityInfos:marshal(os)
end
function CGetLoginSumActivityInfos:unmarshal(os)
end
function CGetLoginSumActivityInfos:sizepolicy(size)
  return size <= 65535
end
return CGetLoginSumActivityInfos
