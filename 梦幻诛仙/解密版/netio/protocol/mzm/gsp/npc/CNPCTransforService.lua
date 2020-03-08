local CNPCTransforService = class("CNPCTransforService")
CNPCTransforService.TYPEID = 12586759
function CNPCTransforService:ctor(npcId, serviceid)
  self.id = 12586759
  self.npcId = npcId or nil
  self.serviceid = serviceid or nil
end
function CNPCTransforService:marshal(os)
  os:marshalInt32(self.npcId)
  os:marshalInt32(self.serviceid)
end
function CNPCTransforService:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  self.serviceid = os:unmarshalInt32()
end
function CNPCTransforService:sizepolicy(size)
  return size <= 65535
end
return CNPCTransforService
