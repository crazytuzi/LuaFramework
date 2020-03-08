local CGetRecordReq = class("CGetRecordReq")
CGetRecordReq.TYPEID = 12594217
function CGetRecordReq:ctor(recordid)
  self.id = 12594217
  self.recordid = recordid or nil
end
function CGetRecordReq:marshal(os)
  os:marshalInt64(self.recordid)
end
function CGetRecordReq:unmarshal(os)
  self.recordid = os:unmarshalInt64()
end
function CGetRecordReq:sizepolicy(size)
  return size <= 65535
end
return CGetRecordReq
