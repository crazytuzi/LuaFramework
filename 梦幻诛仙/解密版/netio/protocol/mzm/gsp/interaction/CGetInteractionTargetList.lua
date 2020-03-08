local CGetInteractionTargetList = class("CGetInteractionTargetList")
CGetInteractionTargetList.TYPEID = 12622594
function CGetInteractionTargetList:ctor(interaction_id)
  self.id = 12622594
  self.interaction_id = interaction_id or nil
end
function CGetInteractionTargetList:marshal(os)
  os:marshalInt32(self.interaction_id)
end
function CGetInteractionTargetList:unmarshal(os)
  self.interaction_id = os:unmarshalInt32()
end
function CGetInteractionTargetList:sizepolicy(size)
  return size <= 65535
end
return CGetInteractionTargetList
