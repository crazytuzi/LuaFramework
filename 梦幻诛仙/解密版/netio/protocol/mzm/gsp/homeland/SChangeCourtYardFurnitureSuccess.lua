local SChangeCourtYardFurnitureSuccess = class("SChangeCourtYardFurnitureSuccess")
SChangeCourtYardFurnitureSuccess.TYPEID = 12605515
function SChangeCourtYardFurnitureSuccess:ctor(furniture_cfg_Id, furniture_uuId, unfurniture_uuId, unfurniture_cfg_Id, change_beautiful_value, furniture_pos)
  self.id = 12605515
  self.furniture_cfg_Id = furniture_cfg_Id or nil
  self.furniture_uuId = furniture_uuId or nil
  self.unfurniture_uuId = unfurniture_uuId or nil
  self.unfurniture_cfg_Id = unfurniture_cfg_Id or nil
  self.change_beautiful_value = change_beautiful_value or nil
  self.furniture_pos = furniture_pos or nil
end
function SChangeCourtYardFurnitureSuccess:marshal(os)
  os:marshalInt32(self.furniture_cfg_Id)
  os:marshalInt64(self.furniture_uuId)
  os:marshalInt64(self.unfurniture_uuId)
  os:marshalInt32(self.unfurniture_cfg_Id)
  os:marshalInt32(self.change_beautiful_value)
  os:marshalInt32(self.furniture_pos)
end
function SChangeCourtYardFurnitureSuccess:unmarshal(os)
  self.furniture_cfg_Id = os:unmarshalInt32()
  self.furniture_uuId = os:unmarshalInt64()
  self.unfurniture_uuId = os:unmarshalInt64()
  self.unfurniture_cfg_Id = os:unmarshalInt32()
  self.change_beautiful_value = os:unmarshalInt32()
  self.furniture_pos = os:unmarshalInt32()
end
function SChangeCourtYardFurnitureSuccess:sizepolicy(size)
  return size <= 65535
end
return SChangeCourtYardFurnitureSuccess
