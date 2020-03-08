local SNPCEnterView = class("SNPCEnterView")
SNPCEnterView.TYPEID = 12590888
function SNPCEnterView:ctor(npcId)
  self.id = 12590888
  self.npcId = npcId or nil
end
function SNPCEnterView:marshal(os)
  os:marshalInt32(self.npcId)
end
function SNPCEnterView:unmarshal(os)
  self.npcId = os:unmarshalInt32()
end
function SNPCEnterView:sizepolicy(size)
  return size <= 65535
end
return SNPCEnterView
