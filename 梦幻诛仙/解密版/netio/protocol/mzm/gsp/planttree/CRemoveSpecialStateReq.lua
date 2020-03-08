local CRemoveSpecialStateReq = class("CRemoveSpecialStateReq")
CRemoveSpecialStateReq.TYPEID = 12611589
function CRemoveSpecialStateReq:ctor(owner_id, activity_cfg_id, special_state_index)
  self.id = 12611589
  self.owner_id = owner_id or nil
  self.activity_cfg_id = activity_cfg_id or nil
  self.special_state_index = special_state_index or nil
end
function CRemoveSpecialStateReq:marshal(os)
  os:marshalInt64(self.owner_id)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.special_state_index)
end
function CRemoveSpecialStateReq:unmarshal(os)
  self.owner_id = os:unmarshalInt64()
  self.activity_cfg_id = os:unmarshalInt32()
  self.special_state_index = os:unmarshalInt32()
end
function CRemoveSpecialStateReq:sizepolicy(size)
  return size <= 65535
end
return CRemoveSpecialStateReq
