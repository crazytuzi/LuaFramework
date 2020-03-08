local SGrapPositionSucBro = class("SGrapPositionSucBro")
SGrapPositionSucBro.TYPEID = 12621581
function SGrapPositionSucBro:ctor(positionId, roleId)
  self.id = 12621581
  self.positionId = positionId or nil
  self.roleId = roleId or nil
end
function SGrapPositionSucBro:marshal(os)
  os:marshalInt32(self.positionId)
  os:marshalInt64(self.roleId)
end
function SGrapPositionSucBro:unmarshal(os)
  self.positionId = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
end
function SGrapPositionSucBro:sizepolicy(size)
  return size <= 65535
end
return SGrapPositionSucBro
