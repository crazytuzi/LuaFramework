local CNPCFightService = class("CNPCFightService")
CNPCFightService.TYPEID = 12586758
function CNPCFightService:ctor(npcId, serviceid)
  self.id = 12586758
  self.npcId = npcId or nil
  self.serviceid = serviceid or nil
end
function CNPCFightService:marshal(os)
  os:marshalInt32(self.npcId)
  os:marshalInt32(self.serviceid)
end
function CNPCFightService:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  self.serviceid = os:unmarshalInt32()
end
function CNPCFightService:sizepolicy(size)
  return size <= 65535
end
return CNPCFightService
