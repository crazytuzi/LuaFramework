local CWingPhaseUp = class("CWingPhaseUp")
CWingPhaseUp.TYPEID = 12596500
function CWingPhaseUp:ctor(index)
  self.id = 12596500
  self.index = index or nil
end
function CWingPhaseUp:marshal(os)
  os:marshalInt32(self.index)
end
function CWingPhaseUp:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CWingPhaseUp:sizepolicy(size)
  return size <= 65535
end
return CWingPhaseUp
