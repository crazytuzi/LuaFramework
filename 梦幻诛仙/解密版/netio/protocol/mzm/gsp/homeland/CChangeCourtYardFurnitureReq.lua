local CChangeCourtYardFurnitureReq = class("CChangeCourtYardFurnitureReq")
CChangeCourtYardFurnitureReq.TYPEID = 12605510
function CChangeCourtYardFurnitureReq:ctor(furniture_cfg_id, furniture_uuId)
  self.id = 12605510
  self.furniture_cfg_id = furniture_cfg_id or nil
  self.furniture_uuId = furniture_uuId or nil
end
function CChangeCourtYardFurnitureReq:marshal(os)
  os:marshalInt32(self.furniture_cfg_id)
  os:marshalInt64(self.furniture_uuId)
end
function CChangeCourtYardFurnitureReq:unmarshal(os)
  self.furniture_cfg_id = os:unmarshalInt32()
  self.furniture_uuId = os:unmarshalInt64()
end
function CChangeCourtYardFurnitureReq:sizepolicy(size)
  return size <= 65535
end
return CChangeCourtYardFurnitureReq
