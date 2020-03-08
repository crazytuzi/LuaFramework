local CUnEquipFabaoReq = class("CUnEquipFabaoReq")
CUnEquipFabaoReq.TYPEID = 12595993
function CUnEquipFabaoReq:ctor(fabaotype)
  self.id = 12595993
  self.fabaotype = fabaotype or nil
end
function CUnEquipFabaoReq:marshal(os)
  os:marshalInt32(self.fabaotype)
end
function CUnEquipFabaoReq:unmarshal(os)
  self.fabaotype = os:unmarshalInt32()
end
function CUnEquipFabaoReq:sizepolicy(size)
  return size <= 65535
end
return CUnEquipFabaoReq
