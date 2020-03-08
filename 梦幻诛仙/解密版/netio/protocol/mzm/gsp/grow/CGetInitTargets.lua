local CGetInitTargets = class("CGetInitTargets")
CGetInitTargets.TYPEID = 12597005
function CGetInitTargets:ctor()
  self.id = 12597005
end
function CGetInitTargets:marshal(os)
end
function CGetInitTargets:unmarshal(os)
end
function CGetInitTargets:sizepolicy(size)
  return size <= 65535
end
return CGetInitTargets
