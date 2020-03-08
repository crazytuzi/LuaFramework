local CJoinParaselene = class("CJoinParaselene")
CJoinParaselene.TYPEID = 12598273
function CJoinParaselene:ctor()
  self.id = 12598273
end
function CJoinParaselene:marshal(os)
end
function CJoinParaselene:unmarshal(os)
end
function CJoinParaselene:sizepolicy(size)
  return size <= 65535
end
return CJoinParaselene
