local CQiuQianReq = class("CQiuQianReq")
CQiuQianReq.TYPEID = 12610818
function CQiuQianReq:ctor(qiuqian_id, sessionid)
  self.id = 12610818
  self.qiuqian_id = qiuqian_id or nil
  self.sessionid = sessionid or nil
end
function CQiuQianReq:marshal(os)
  os:marshalInt32(self.qiuqian_id)
  os:marshalInt64(self.sessionid)
end
function CQiuQianReq:unmarshal(os)
  self.qiuqian_id = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CQiuQianReq:sizepolicy(size)
  return size <= 65535
end
return CQiuQianReq
