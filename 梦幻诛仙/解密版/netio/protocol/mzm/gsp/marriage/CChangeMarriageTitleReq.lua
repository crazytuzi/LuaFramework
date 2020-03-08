local CChangeMarriageTitleReq = class("CChangeMarriageTitleReq")
CChangeMarriageTitleReq.TYPEID = 12599831
function CChangeMarriageTitleReq:ctor(marriageTitleCfgid)
  self.id = 12599831
  self.marriageTitleCfgid = marriageTitleCfgid or nil
end
function CChangeMarriageTitleReq:marshal(os)
  os:marshalInt32(self.marriageTitleCfgid)
end
function CChangeMarriageTitleReq:unmarshal(os)
  self.marriageTitleCfgid = os:unmarshalInt32()
end
function CChangeMarriageTitleReq:sizepolicy(size)
  return size <= 65535
end
return CChangeMarriageTitleReq
