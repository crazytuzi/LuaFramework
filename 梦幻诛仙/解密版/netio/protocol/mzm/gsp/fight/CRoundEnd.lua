local CRoundEnd = class("CRoundEnd")
CRoundEnd.TYPEID = 12594208
function CRoundEnd:ctor()
  self.id = 12594208
end
function CRoundEnd:marshal(os)
end
function CRoundEnd:unmarshal(os)
end
function CRoundEnd:sizepolicy(size)
  return size <= 65535
end
return CRoundEnd
