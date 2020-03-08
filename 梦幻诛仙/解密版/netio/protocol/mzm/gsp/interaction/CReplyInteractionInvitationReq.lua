local CReplyInteractionInvitationReq = class("CReplyInteractionInvitationReq")
CReplyInteractionInvitationReq.TYPEID = 12622598
CReplyInteractionInvitationReq.USER = 0
CReplyInteractionInvitationReq.ROLE_MODEL_NOT_COMPATIBLE = 1
function CReplyInteractionInvitationReq:ctor(active_role_id, interaction_id, is_accepted, reason)
  self.id = 12622598
  self.active_role_id = active_role_id or nil
  self.interaction_id = interaction_id or nil
  self.is_accepted = is_accepted or nil
  self.reason = reason or nil
end
function CReplyInteractionInvitationReq:marshal(os)
  os:marshalInt64(self.active_role_id)
  os:marshalInt32(self.interaction_id)
  os:marshalInt32(self.is_accepted)
  os:marshalInt32(self.reason)
end
function CReplyInteractionInvitationReq:unmarshal(os)
  self.active_role_id = os:unmarshalInt64()
  self.interaction_id = os:unmarshalInt32()
  self.is_accepted = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
end
function CReplyInteractionInvitationReq:sizepolicy(size)
  return size <= 65535
end
return CReplyInteractionInvitationReq
