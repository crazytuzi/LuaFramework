local SRecallAllBrd = class("SRecallAllBrd")
SRecallAllBrd.TYPEID = 12588310
function SRecallAllBrd:ctor()
  self.id = 12588310
end
function SRecallAllBrd:marshal(os)
end
function SRecallAllBrd:unmarshal(os)
end
function SRecallAllBrd:sizepolicy(size)
  return size <= 65535
end
return SRecallAllBrd
