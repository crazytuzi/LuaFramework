local SSynRoleCardInfo = class("SSynRoleCardInfo")
SSynRoleCardInfo.TYPEID = 12624416
function SSynRoleCardInfo:ctor(current_card_cfg_id, current_card_level, fight_count, start_time, overlay_count, visible)
  self.id = 12624416
  self.current_card_cfg_id = current_card_cfg_id or nil
  self.current_card_level = current_card_level or nil
  self.fight_count = fight_count or nil
  self.start_time = start_time or nil
  self.overlay_count = overlay_count or nil
  self.visible = visible or nil
end
function SSynRoleCardInfo:marshal(os)
  os:marshalInt32(self.current_card_cfg_id)
  os:marshalInt32(self.current_card_level)
  os:marshalInt32(self.fight_count)
  os:marshalInt64(self.start_time)
  os:marshalInt32(self.overlay_count)
  os:marshalUInt8(self.visible)
end
function SSynRoleCardInfo:unmarshal(os)
  self.current_card_cfg_id = os:unmarshalInt32()
  self.current_card_level = os:unmarshalInt32()
  self.fight_count = os:unmarshalInt32()
  self.start_time = os:unmarshalInt64()
  self.overlay_count = os:unmarshalInt32()
  self.visible = os:unmarshalUInt8()
end
function SSynRoleCardInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleCardInfo
