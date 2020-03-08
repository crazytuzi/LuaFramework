local CJigsawSuccess = class("CJigsawSuccess")
CJigsawSuccess.TYPEID = 12598281
function CJigsawSuccess:ctor()
  self.id = 12598281
end
function CJigsawSuccess:marshal(os)
end
function CJigsawSuccess:unmarshal(os)
end
function CJigsawSuccess:sizepolicy(size)
  return size <= 65535
end
return CJigsawSuccess
