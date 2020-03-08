local CApprenticeRelieveShiTuRelation = class("CApprenticeRelieveShiTuRelation")
CApprenticeRelieveShiTuRelation.TYPEID = 12601616
function CApprenticeRelieveShiTuRelation:ctor()
  self.id = 12601616
end
function CApprenticeRelieveShiTuRelation:marshal(os)
end
function CApprenticeRelieveShiTuRelation:unmarshal(os)
end
function CApprenticeRelieveShiTuRelation:sizepolicy(size)
  return size <= 65535
end
return CApprenticeRelieveShiTuRelation
