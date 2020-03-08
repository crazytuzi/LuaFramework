local CSignPreciousDrawLottery = class("CSignPreciousDrawLottery")
CSignPreciousDrawLottery.TYPEID = 12593430
function CSignPreciousDrawLottery:ctor()
  self.id = 12593430
end
function CSignPreciousDrawLottery:marshal(os)
end
function CSignPreciousDrawLottery:unmarshal(os)
end
function CSignPreciousDrawLottery:sizepolicy(size)
  return size <= 65535
end
return CSignPreciousDrawLottery
