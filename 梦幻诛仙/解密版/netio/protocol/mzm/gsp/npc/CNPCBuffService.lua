local CNPCBuffService = class("CNPCBuffService")
CNPCBuffService.TYPEID = 12586760
function CNPCBuffService:ctor(npcId, serviceid)
  self.id = 12586760
  self.npcId = npcId or nil
  self.serviceid = serviceid or nil
end
function CNPCBuffService:marshal(os)
  os:marshalInt32(self.npcId)
  os:marshalInt32(self.serviceid)
end
function CNPCBuffService:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  self.serviceid = os:unmarshalInt32()
end
function CNPCBuffService:sizepolicy(size)
  return size <= 65535
end
return CNPCBuffService
