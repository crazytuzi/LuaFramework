local SInviteInteractionFail = class("SInviteInteractionFail")
SInviteInteractionFail.TYPEID = 12622593
SInviteInteractionFail.ACTIVE_ROLE_BANNED = 1
SInviteInteractionFail.ACTIVE_ROLE_LEVEL_TOO_LOW = 2
SInviteInteractionFail.PASSIVE_ROLE_LEVEL_TOO_LOW = 3
SInviteInteractionFail.UNAVAILABLE_TO_SAME_GENDER = 4
SInviteInteractionFail.PASSIVE_ROLE_NOT_TEAMMATE_NOT_SINGLE = 5
SInviteInteractionFail.ACTIVE_ROLE_IN_INVITING = 6
SInviteInteractionFail.ACTIVE_ROLE_BEING_INVITED = 7
SInviteInteractionFail.PASSIVE_ROLE_IN_INVITING = 8
SInviteInteractionFail.PASSIVE_ROLE_BEING_INVITED = 9
SInviteInteractionFail.IN_DIFFERENT_SCENE = 10
SInviteInteractionFail.PASSIVE_ROLE_OFFLINE = 11
SInviteInteractionFail.PASSIVE_ROLE_IN_COMBAT = 12
SInviteInteractionFail.PASSIVE_ROLE_IN_WATCHING_MOON = 13
SInviteInteractionFail.PASSIVE_ROLE_IN_ESCORTING = 14
SInviteInteractionFail.PASSIVE_ROLE_IN_MARRIAGE_PARADE = 15
SInviteInteractionFail.PASSIVE_ROLE_IN_PRISON = 16
SInviteInteractionFail.PASSIVE_ROLE_IN_OBSERVING_FIGHT = 17
SInviteInteractionFail.ACTIVE_ROLE_IN_MOVING = 18
SInviteInteractionFail.ACTIVE_ROLE_ON_MULTI_ROLE_MOUNT = 19
SInviteInteractionFail.PASSIVE_ROLE_ON_MULTI_ROLE_MOUNT = 20
SInviteInteractionFail.ACTIVE_ROLE_NOT_LEADER_PASSIVE_ROLE_NOT_TEAMMATE = 21
function SInviteInteractionFail:ctor(reason, passive_role_id, interaction_id)
  self.id = 12622593
  self.reason = reason or nil
  self.passive_role_id = passive_role_id or nil
  self.interaction_id = interaction_id or nil
end
function SInviteInteractionFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt64(self.passive_role_id)
  os:marshalInt32(self.interaction_id)
end
function SInviteInteractionFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.passive_role_id = os:unmarshalInt64()
  self.interaction_id = os:unmarshalInt32()
end
function SInviteInteractionFail:sizepolicy(size)
  return size <= 65535
end
return SInviteInteractionFail
