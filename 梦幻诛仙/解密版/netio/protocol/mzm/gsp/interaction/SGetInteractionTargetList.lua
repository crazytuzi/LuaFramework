local SGetInteractionTargetList = class("SGetInteractionTargetList")
SGetInteractionTargetList.TYPEID = 12622599
function SGetInteractionTargetList:ctor(interaction_id, target_list)
  self.id = 12622599
  self.interaction_id = interaction_id or nil
  self.target_list = target_list or {}
end
function SGetInteractionTargetList:marshal(os)
  os:marshalInt32(self.interaction_id)
  os:marshalCompactUInt32(table.getn(self.target_list))
  for _, v in ipairs(self.target_list) do
    v:marshal(os)
  end
end
function SGetInteractionTargetList:unmarshal(os)
  self.interaction_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.interaction.RoleListItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.target_list, v)
  end
end
function SGetInteractionTargetList:sizepolicy(size)
  return size <= 65535
end
return SGetInteractionTargetList
