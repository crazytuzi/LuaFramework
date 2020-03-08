local SAcceptInteractionInvitationFail = class("SAcceptInteractionInvitationFail")
SAcceptInteractionInvitationFail.TYPEID = 12622601
SAcceptInteractionInvitationFail.SAME_TEAM_ACTIVE_ROLE_AWAY = 1
SAcceptInteractionInvitationFail.DIFFERENT_TEAM_PASSIVE_ROLE_NOT_SINGLE = 2
SAcceptInteractionInvitationFail.TELEPORT_FAILED = 3
SAcceptInteractionInvitationFail.SYNC_FLY_STATUS_FAILED = 4
SAcceptInteractionInvitationFail.ACTIVE_ROLE_STATUS_CONFLICT = 5
SAcceptInteractionInvitationFail.ACTIVE_ROLE_IN_MOVING = 6
function SAcceptInteractionInvitationFail:ctor(reason, active_role_id, interaction_id)
  self.id = 12622601
  self.reason = reason or nil
  self.active_role_id = active_role_id or nil
  self.interaction_id = interaction_id or nil
end
function SAcceptInteractionInvitationFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt64(self.active_role_id)
  os:marshalInt32(self.interaction_id)
end
function SAcceptInteractionInvitationFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.active_role_id = os:unmarshalInt64()
  self.interaction_id = os:unmarshalInt32()
end
function SAcceptInteractionInvitationFail:sizepolicy(size)
  return size <= 65535
end
return SAcceptInteractionInvitationFail
