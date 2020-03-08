local CActiveNewSurpriseGraphRep = class("CActiveNewSurpriseGraphRep")
CActiveNewSurpriseGraphRep.TYPEID = 12592162
function CActiveNewSurpriseGraphRep:ctor()
  self.id = 12592162
end
function CActiveNewSurpriseGraphRep:marshal(os)
end
function CActiveNewSurpriseGraphRep:unmarshal(os)
end
function CActiveNewSurpriseGraphRep:sizepolicy(size)
  return size <= 65535
end
return CActiveNewSurpriseGraphRep
