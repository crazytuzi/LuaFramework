local CReceiveMasterTaskRewardReq = class("CReceiveMasterTaskRewardReq")
CReceiveMasterTaskRewardReq.TYPEID = 12601643
function CReceiveMasterTaskRewardReq:ctor(role_id, graph_id, task_id)
  self.id = 12601643
  self.role_id = role_id or nil
  self.graph_id = graph_id or nil
  self.task_id = task_id or nil
end
function CReceiveMasterTaskRewardReq:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.graph_id)
  os:marshalInt32(self.task_id)
end
function CReceiveMasterTaskRewardReq:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.graph_id = os:unmarshalInt32()
  self.task_id = os:unmarshalInt32()
end
function CReceiveMasterTaskRewardReq:sizepolicy(size)
  return size <= 65535
end
return CReceiveMasterTaskRewardReq
