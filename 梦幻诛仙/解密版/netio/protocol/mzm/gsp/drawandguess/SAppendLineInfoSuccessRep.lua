local SAppendLineInfoSuccessRep = class("SAppendLineInfoSuccessRep")
SAppendLineInfoSuccessRep.TYPEID = 12617247
function SAppendLineInfoSuccessRep:ctor()
  self.id = 12617247
end
function SAppendLineInfoSuccessRep:marshal(os)
end
function SAppendLineInfoSuccessRep:unmarshal(os)
end
function SAppendLineInfoSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SAppendLineInfoSuccessRep
