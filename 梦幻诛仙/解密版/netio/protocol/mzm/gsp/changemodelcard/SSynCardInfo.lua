local SSynCardInfo = class("SSynCardInfo")
SSynCardInfo.TYPEID = 12624394
function SSynCardInfo:ctor(card_info_map, current_card_cfg_id, current_card_level, visible, fight_count, start_time, overlay_count)
  self.id = 12624394
  self.card_info_map = card_info_map or {}
  self.current_card_cfg_id = current_card_cfg_id or nil
  self.current_card_level = current_card_level or nil
  self.visible = visible or nil
  self.fight_count = fight_count or nil
  self.start_time = start_time or nil
  self.overlay_count = overlay_count or nil
end
function SSynCardInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.card_info_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.card_info_map) do
      os:marshalInt64(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.current_card_cfg_id)
  os:marshalInt32(self.current_card_level)
  os:marshalUInt8(self.visible)
  os:marshalInt32(self.fight_count)
  os:marshalInt64(self.start_time)
  os:marshalInt32(self.overlay_count)
end
function SSynCardInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.changemodelcard.CardInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.card_info_map[k] = v
  end
  self.current_card_cfg_id = os:unmarshalInt32()
  self.current_card_level = os:unmarshalInt32()
  self.visible = os:unmarshalUInt8()
  self.fight_count = os:unmarshalInt32()
  self.start_time = os:unmarshalInt64()
  self.overlay_count = os:unmarshalInt32()
end
function SSynCardInfo:sizepolicy(size)
  return size <= 65535
end
return SSynCardInfo
