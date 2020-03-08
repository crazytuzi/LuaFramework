local CCommitItemReq = class("CCommitItemReq")
CCommitItemReq.TYPEID = 12594437
function CCommitItemReq:ctor(position, activity_cfg_id, npc_id, entity_instance_id)
  self.id = 12594437
  self.position = position or nil
  self.activity_cfg_id = activity_cfg_id or nil
  self.npc_id = npc_id or nil
  self.entity_instance_id = entity_instance_id or nil
end
function CCommitItemReq:marshal(os)
  os:marshalInt32(self.position)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.npc_id)
  os:marshalInt64(self.entity_instance_id)
end
function CCommitItemReq:unmarshal(os)
  self.position = os:unmarshalInt32()
  self.activity_cfg_id = os:unmarshalInt32()
  self.npc_id = os:unmarshalInt32()
  self.entity_instance_id = os:unmarshalInt64()
end
function CCommitItemReq:sizepolicy(size)
  return size <= 65535
end
return CCommitItemReq
