local EnterPosition = require("netio.protocol.mzm.gsp.map.EnterPosition")
local SModelNPCEnterView = class("SModelNPCEnterView")
SModelNPCEnterView.TYPEID = 12590900
function SModelNPCEnterView:ctor(npcId, modelInfo, posinit)
  self.id = 12590900
  self.npcId = npcId or nil
  self.modelInfo = modelInfo or nil
  self.posinit = posinit or EnterPosition.new()
end
function SModelNPCEnterView:marshal(os)
  os:marshalInt32(self.npcId)
  os:marshalOctets(self.modelInfo)
  self.posinit:marshal(os)
end
function SModelNPCEnterView:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  self.modelInfo = os:unmarshalOctets()
  self.posinit = EnterPosition.new()
  self.posinit:unmarshal(os)
end
function SModelNPCEnterView:sizepolicy(size)
  return size <= 65535
end
return SModelNPCEnterView
