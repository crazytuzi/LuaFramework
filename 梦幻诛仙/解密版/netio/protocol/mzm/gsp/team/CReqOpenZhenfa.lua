local CReqOpenZhenfa = class("CReqOpenZhenfa")
CReqOpenZhenfa.TYPEID = 12588326
function CReqOpenZhenfa:ctor(openZhenfaId)
  self.id = 12588326
  self.openZhenfaId = openZhenfaId or nil
end
function CReqOpenZhenfa:marshal(os)
  os:marshalInt32(self.openZhenfaId)
end
function CReqOpenZhenfa:unmarshal(os)
  self.openZhenfaId = os:unmarshalInt32()
end
function CReqOpenZhenfa:sizepolicy(size)
  return size <= 65535
end
return CReqOpenZhenfa
