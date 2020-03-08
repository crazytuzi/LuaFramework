local SSynShiTuTaskStatus = class("SSynShiTuTaskStatus")
SSynShiTuTaskStatus.TYPEID = 12601641
function SSynShiTuTaskStatus:ctor(role_id, graph_id, task_id, task_state)
  self.id = 12601641
  self.role_id = role_id or nil
  self.graph_id = graph_id or nil
  self.task_id = task_id or nil
  self.task_state = task_state or nil
end
function SSynShiTuTaskStatus:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.graph_id)
  os:marshalInt32(self.task_id)
  os:marshalInt32(self.task_state)
end
function SSynShiTuTaskStatus:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.graph_id = os:unmarshalInt32()
  self.task_id = os:unmarshalInt32()
  self.task_state = os:unmarshalInt32()
end
function SSynShiTuTaskStatus:sizepolicy(size)
  return size <= 65535
end
return SSynShiTuTaskStatus
