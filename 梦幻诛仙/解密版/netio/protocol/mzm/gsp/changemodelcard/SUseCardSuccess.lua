local SUseCardSuccess = class("SUseCardSuccess")
SUseCardSuccess.TYPEID = 12624387
function SUseCardSuccess:ctor(card_id, card_cfg_id, use_count)
  self.id = 12624387
  self.card_id = card_id or nil
  self.card_cfg_id = card_cfg_id or nil
  self.use_count = use_count or nil
end
function SUseCardSuccess:marshal(os)
  os:marshalInt64(self.card_id)
  os:marshalInt32(self.card_cfg_id)
  os:marshalInt32(self.use_count)
end
function SUseCardSuccess:unmarshal(os)
  self.card_id = os:unmarshalInt64()
  self.card_cfg_id = os:unmarshalInt32()
  self.use_count = os:unmarshalInt32()
end
function SUseCardSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseCardSuccess
