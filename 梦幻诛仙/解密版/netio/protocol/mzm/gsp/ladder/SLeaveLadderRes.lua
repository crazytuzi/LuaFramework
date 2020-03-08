local SLeaveLadderRes = class("SLeaveLadderRes")
SLeaveLadderRes.TYPEID = 12607252
function SLeaveLadderRes:ctor()
  self.id = 12607252
end
function SLeaveLadderRes:marshal(os)
end
function SLeaveLadderRes:unmarshal(os)
end
function SLeaveLadderRes:sizepolicy(size)
  return size <= 65535
end
return SLeaveLadderRes
