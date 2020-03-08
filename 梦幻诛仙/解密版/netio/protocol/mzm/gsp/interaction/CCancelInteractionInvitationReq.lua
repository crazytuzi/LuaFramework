local CCancelInteractionInvitationReq = class("CCancelInteractionInvitationReq")
CCancelInteractionInvitationReq.TYPEID = 12622596
function CCancelInteractionInvitationReq:ctor(passive_role_id, interaction_id)
  self.id = 12622596
  self.passive_role_id = passive_role_id or nil
  self.interaction_id = interaction_id or nil
end
function CCancelInteractionInvitationReq:marshal(os)
  os:marshalInt64(self.passive_role_id)
  os:marshalInt32(self.interaction_id)
end
function CCancelInteractionInvitationReq:unmarshal(os)
  self.passive_role_id = os:unmarshalInt64()
  self.interaction_id = os:unmarshalInt32()
end
function CCancelInteractionInvitationReq:sizepolicy(size)
  return size <= 65535
end
return CCancelInteractionInvitationReq
