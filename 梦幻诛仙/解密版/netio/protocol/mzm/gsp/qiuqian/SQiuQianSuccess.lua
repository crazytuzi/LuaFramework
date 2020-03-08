local SQiuQianSuccess = class("SQiuQianSuccess")
SQiuQianSuccess.TYPEID = 12610819
function SQiuQianSuccess:ctor(qiuqian_id, sort_id)
  self.id = 12610819
  self.qiuqian_id = qiuqian_id or nil
  self.sort_id = sort_id or nil
end
function SQiuQianSuccess:marshal(os)
  os:marshalInt32(self.qiuqian_id)
  os:marshalInt32(self.sort_id)
end
function SQiuQianSuccess:unmarshal(os)
  self.qiuqian_id = os:unmarshalInt32()
  self.sort_id = os:unmarshalInt32()
end
function SQiuQianSuccess:sizepolicy(size)
  return size <= 65535
end
return SQiuQianSuccess
