local CInviteInteractionReq = class("CInviteInteractionReq")
CInviteInteractionReq.TYPEID = 12622602
function CInviteInteractionReq:ctor(passive_role_id, interaction_id)
  self.id = 12622602
  self.passive_role_id = passive_role_id or nil
  self.interaction_id = interaction_id or nil
end
function CInviteInteractionReq:marshal(os)
  os:marshalInt64(self.passive_role_id)
  os:marshalInt32(self.interaction_id)
end
function CInviteInteractionReq:unmarshal(os)
  self.passive_role_id = os:unmarshalInt64()
  self.interaction_id = os:unmarshalInt32()
end
function CInviteInteractionReq:sizepolicy(size)
  return size <= 65535
end
return CInviteInteractionReq
