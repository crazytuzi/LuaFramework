local CDyeAircraft = class("CDyeAircraft")
CDyeAircraft.TYPEID = 12624643
function CDyeAircraft:ctor(aircraft_cfg_id, dye_color_id, is_use_yuan_bao, client_need_yuan_bao, client_yuan_bao)
  self.id = 12624643
  self.aircraft_cfg_id = aircraft_cfg_id or nil
  self.dye_color_id = dye_color_id or nil
  self.is_use_yuan_bao = is_use_yuan_bao or nil
  self.client_need_yuan_bao = client_need_yuan_bao or nil
  self.client_yuan_bao = client_yuan_bao or nil
end
function CDyeAircraft:marshal(os)
  os:marshalInt32(self.aircraft_cfg_id)
  os:marshalInt32(self.dye_color_id)
  os:marshalInt32(self.is_use_yuan_bao)
  os:marshalInt32(self.client_need_yuan_bao)
  os:marshalInt64(self.client_yuan_bao)
end
function CDyeAircraft:unmarshal(os)
  self.aircraft_cfg_id = os:unmarshalInt32()
  self.dye_color_id = os:unmarshalInt32()
  self.is_use_yuan_bao = os:unmarshalInt32()
  self.client_need_yuan_bao = os:unmarshalInt32()
  self.client_yuan_bao = os:unmarshalInt64()
end
function CDyeAircraft:sizepolicy(size)
  return size <= 65535
end
return CDyeAircraft
