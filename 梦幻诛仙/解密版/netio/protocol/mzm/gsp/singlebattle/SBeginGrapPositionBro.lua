local SBeginGrapPositionBro = class("SBeginGrapPositionBro")
SBeginGrapPositionBro.TYPEID = 12621582
function SBeginGrapPositionBro:ctor(positionId, roleId, endTime)
  self.id = 12621582
  self.positionId = positionId or nil
  self.roleId = roleId or nil
  self.endTime = endTime or nil
end
function SBeginGrapPositionBro:marshal(os)
  os:marshalInt32(self.positionId)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.endTime)
end
function SBeginGrapPositionBro:unmarshal(os)
  self.positionId = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.endTime = os:unmarshalInt32()
end
function SBeginGrapPositionBro:sizepolicy(size)
  return size <= 65535
end
return SBeginGrapPositionBro
