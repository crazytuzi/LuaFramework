local CGrapPositionReq = class("CGrapPositionReq")
CGrapPositionReq.TYPEID = 12621586
function CGrapPositionReq:ctor(positionId)
  self.id = 12621586
  self.positionId = positionId or nil
end
function CGrapPositionReq:marshal(os)
  os:marshalInt32(self.positionId)
end
function CGrapPositionReq:unmarshal(os)
  self.positionId = os:unmarshalInt32()
end
function CGrapPositionReq:sizepolicy(size)
  return size <= 65535
end
return CGrapPositionReq
