local SRecallChildSuccess = class("SRecallChildSuccess")
SRecallChildSuccess.TYPEID = 12609441
function SRecallChildSuccess:ctor(child_id, left_recall_times)
  self.id = 12609441
  self.child_id = child_id or nil
  self.left_recall_times = left_recall_times or nil
end
function SRecallChildSuccess:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalInt32(self.left_recall_times)
end
function SRecallChildSuccess:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.left_recall_times = os:unmarshalInt32()
end
function SRecallChildSuccess:sizepolicy(size)
  return size <= 65535
end
return SRecallChildSuccess
