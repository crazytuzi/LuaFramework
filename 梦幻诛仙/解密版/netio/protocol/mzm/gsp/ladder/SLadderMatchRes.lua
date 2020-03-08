local SLadderMatchRes = class("SLadderMatchRes")
SLadderMatchRes.TYPEID = 12607234
function SLadderMatchRes:ctor()
  self.id = 12607234
end
function SLadderMatchRes:marshal(os)
end
function SLadderMatchRes:unmarshal(os)
end
function SLadderMatchRes:sizepolicy(size)
  return size <= 65535
end
return SLadderMatchRes
