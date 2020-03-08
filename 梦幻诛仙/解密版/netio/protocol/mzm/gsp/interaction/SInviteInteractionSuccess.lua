local SInviteInteractionSuccess = class("SInviteInteractionSuccess")
SInviteInteractionSuccess.TYPEID = 12622604
function SInviteInteractionSuccess:ctor(passive_role_id, interaction_id)
  self.id = 12622604
  self.passive_role_id = passive_role_id or nil
  self.interaction_id = interaction_id or nil
end
function SInviteInteractionSuccess:marshal(os)
  os:marshalInt64(self.passive_role_id)
  os:marshalInt32(self.interaction_id)
end
function SInviteInteractionSuccess:unmarshal(os)
  self.passive_role_id = os:unmarshalInt64()
  self.interaction_id = os:unmarshalInt32()
end
function SInviteInteractionSuccess:sizepolicy(size)
  return size <= 65535
end
return SInviteInteractionSuccess
