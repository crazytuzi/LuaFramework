local CJigsawFail = class("CJigsawFail")
CJigsawFail.TYPEID = 12598283
function CJigsawFail:ctor()
  self.id = 12598283
end
function CJigsawFail:marshal(os)
end
function CJigsawFail:unmarshal(os)
end
function CJigsawFail:sizepolicy(size)
  return size <= 65535
end
return CJigsawFail
