local SJigsawFinishRes = class("SJigsawFinishRes")
SJigsawFinishRes.TYPEID = 12598282
function SJigsawFinishRes:ctor()
  self.id = 12598282
end
function SJigsawFinishRes:marshal(os)
end
function SJigsawFinishRes:unmarshal(os)
end
function SJigsawFinishRes:sizepolicy(size)
  return size <= 65535
end
return SJigsawFinishRes
