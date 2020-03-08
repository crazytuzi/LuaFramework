local SNotifyCancelInteractionInvitation = class("SNotifyCancelInteractionInvitation")
SNotifyCancelInteractionInvitation.TYPEID = 12622595
function SNotifyCancelInteractionInvitation:ctor(active_role_id, interaction_id)
  self.id = 12622595
  self.active_role_id = active_role_id or nil
  self.interaction_id = interaction_id or nil
end
function SNotifyCancelInteractionInvitation:marshal(os)
  os:marshalInt64(self.active_role_id)
  os:marshalInt32(self.interaction_id)
end
function SNotifyCancelInteractionInvitation:unmarshal(os)
  self.active_role_id = os:unmarshalInt64()
  self.interaction_id = os:unmarshalInt32()
end
function SNotifyCancelInteractionInvitation:sizepolicy(size)
  return size <= 65535
end
return SNotifyCancelInteractionInvitation
