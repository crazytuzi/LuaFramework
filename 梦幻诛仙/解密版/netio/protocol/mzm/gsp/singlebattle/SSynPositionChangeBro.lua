local PositionData = require("netio.protocol.mzm.gsp.singlebattle.PositionData")
local SSynPositionChangeBro = class("SSynPositionChangeBro")
SSynPositionChangeBro.TYPEID = 12621583
function SSynPositionChangeBro:ctor(positionId, positionData)
  self.id = 12621583
  self.positionId = positionId or nil
  self.positionData = positionData or PositionData.new()
end
function SSynPositionChangeBro:marshal(os)
  os:marshalInt32(self.positionId)
  self.positionData:marshal(os)
end
function SSynPositionChangeBro:unmarshal(os)
  self.positionId = os:unmarshalInt32()
  self.positionData = PositionData.new()
  self.positionData:unmarshal(os)
end
function SSynPositionChangeBro:sizepolicy(size)
  return size <= 65535
end
return SSynPositionChangeBro
