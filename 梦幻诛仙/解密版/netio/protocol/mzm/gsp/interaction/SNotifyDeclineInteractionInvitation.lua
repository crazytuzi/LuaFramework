local SNotifyDeclineInteractionInvitation = class("SNotifyDeclineInteractionInvitation")
SNotifyDeclineInteractionInvitation.TYPEID = 12622600
function SNotifyDeclineInteractionInvitation:ctor(passive_role_id, interaction_id, reason)
  self.id = 12622600
  self.passive_role_id = passive_role_id or nil
  self.interaction_id = interaction_id or nil
  self.reason = reason or nil
end
function SNotifyDeclineInteractionInvitation:marshal(os)
  os:marshalInt64(self.passive_role_id)
  os:marshalInt32(self.interaction_id)
  os:marshalInt32(self.reason)
end
function SNotifyDeclineInteractionInvitation:unmarshal(os)
  self.passive_role_id = os:unmarshalInt64()
  self.interaction_id = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
end
function SNotifyDeclineInteractionInvitation:sizepolicy(size)
  return size <= 65535
end
return SNotifyDeclineInteractionInvitation
