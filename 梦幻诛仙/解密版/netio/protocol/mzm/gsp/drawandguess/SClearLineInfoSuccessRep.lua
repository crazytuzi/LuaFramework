local SClearLineInfoSuccessRep = class("SClearLineInfoSuccessRep")
SClearLineInfoSuccessRep.TYPEID = 12617255
function SClearLineInfoSuccessRep:ctor()
  self.id = 12617255
end
function SClearLineInfoSuccessRep:marshal(os)
end
function SClearLineInfoSuccessRep:unmarshal(os)
end
function SClearLineInfoSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SClearLineInfoSuccessRep
