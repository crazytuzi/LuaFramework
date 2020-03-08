local CReceiveShiTuTaskReq = class("CReceiveShiTuTaskReq")
CReceiveShiTuTaskReq.TYPEID = 12601632
function CReceiveShiTuTaskReq:ctor(graph_id, task_id)
  self.id = 12601632
  self.graph_id = graph_id or nil
  self.task_id = task_id or nil
end
function CReceiveShiTuTaskReq:marshal(os)
  os:marshalInt32(self.graph_id)
  os:marshalInt32(self.task_id)
end
function CReceiveShiTuTaskReq:unmarshal(os)
  self.graph_id = os:unmarshalInt32()
  self.task_id = os:unmarshalInt32()
end
function CReceiveShiTuTaskReq:sizepolicy(size)
  return size <= 65535
end
return CReceiveShiTuTaskReq
