local SNotifyStartInteraction = class("SNotifyStartInteraction")
SNotifyStartInteraction.TYPEID = 12622597
function SNotifyStartInteraction:ctor(active_role_id, passive_role_id, inviter_role_id, invitee_role_id, interaction_id)
  self.id = 12622597
  self.active_role_id = active_role_id or nil
  self.passive_role_id = passive_role_id or nil
  self.inviter_role_id = inviter_role_id or nil
  self.invitee_role_id = invitee_role_id or nil
  self.interaction_id = interaction_id or nil
end
function SNotifyStartInteraction:marshal(os)
  os:marshalInt64(self.active_role_id)
  os:marshalInt64(self.passive_role_id)
  os:marshalInt64(self.inviter_role_id)
  os:marshalInt64(self.invitee_role_id)
  os:marshalInt32(self.interaction_id)
end
function SNotifyStartInteraction:unmarshal(os)
  self.active_role_id = os:unmarshalInt64()
  self.passive_role_id = os:unmarshalInt64()
  self.inviter_role_id = os:unmarshalInt64()
  self.invitee_role_id = os:unmarshalInt64()
  self.interaction_id = os:unmarshalInt32()
end
function SNotifyStartInteraction:sizepolicy(size)
  return size <= 65535
end
return SNotifyStartInteraction
