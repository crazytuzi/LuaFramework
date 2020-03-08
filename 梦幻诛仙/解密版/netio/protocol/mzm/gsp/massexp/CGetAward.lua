local CGetAward = class("CGetAward")
CGetAward.TYPEID = 12608267
function CGetAward:ctor()
  self.id = 12608267
end
function CGetAward:marshal(os)
end
function CGetAward:unmarshal(os)
end
function CGetAward:sizepolicy(size)
  return size <= 65535
end
return CGetAward
