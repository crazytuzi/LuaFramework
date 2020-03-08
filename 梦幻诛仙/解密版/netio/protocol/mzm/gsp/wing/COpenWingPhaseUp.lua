local COpenWingPhaseUp = class("COpenWingPhaseUp")
COpenWingPhaseUp.TYPEID = 12596511
function COpenWingPhaseUp:ctor(index)
  self.id = 12596511
  self.index = index or nil
end
function COpenWingPhaseUp:marshal(os)
  os:marshalInt32(self.index)
end
function COpenWingPhaseUp:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function COpenWingPhaseUp:sizepolicy(size)
  return size <= 65535
end
return COpenWingPhaseUp
