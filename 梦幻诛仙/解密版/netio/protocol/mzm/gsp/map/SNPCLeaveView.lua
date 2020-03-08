local SNPCLeaveView = class("SNPCLeaveView")
SNPCLeaveView.TYPEID = 12590870
function SNPCLeaveView:ctor(npcId)
  self.id = 12590870
  self.npcId = npcId or nil
end
function SNPCLeaveView:marshal(os)
  os:marshalInt32(self.npcId)
end
function SNPCLeaveView:unmarshal(os)
  self.npcId = os:unmarshalInt32()
end
function SNPCLeaveView:sizepolicy(size)
  return size <= 65535
end
return SNPCLeaveView
