local SNotifyReceiveInteractionInvitation = class("SNotifyReceiveInteractionInvitation")
SNotifyReceiveInteractionInvitation.TYPEID = 12622603
function SNotifyReceiveInteractionInvitation:ctor(active_role_id, active_role_name, interaction_id)
  self.id = 12622603
  self.active_role_id = active_role_id or nil
  self.active_role_name = active_role_name or nil
  self.interaction_id = interaction_id or nil
end
function SNotifyReceiveInteractionInvitation:marshal(os)
  os:marshalInt64(self.active_role_id)
  os:marshalOctets(self.active_role_name)
  os:marshalInt32(self.interaction_id)
end
function SNotifyReceiveInteractionInvitation:unmarshal(os)
  self.active_role_id = os:unmarshalInt64()
  self.active_role_name = os:unmarshalOctets()
  self.interaction_id = os:unmarshalInt32()
end
function SNotifyReceiveInteractionInvitation:sizepolicy(size)
  return size <= 65535
end
return SNotifyReceiveInteractionInvitation
