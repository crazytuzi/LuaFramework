local CClientTakeRedGift = class("CClientTakeRedGift")
CClientTakeRedGift.TYPEID = 12604940
function CClientTakeRedGift:ctor()
  self.id = 12604940
end
function CClientTakeRedGift:marshal(os)
end
function CClientTakeRedGift:unmarshal(os)
end
function CClientTakeRedGift:sizepolicy(size)
  return size <= 65535
end
return CClientTakeRedGift
