local CGetRealtimeRecordReq = class("CGetRealtimeRecordReq")
CGetRealtimeRecordReq.TYPEID = 12594221
function CGetRealtimeRecordReq:ctor(recordid)
  self.id = 12594221
  self.recordid = recordid or nil
end
function CGetRealtimeRecordReq:marshal(os)
  os:marshalInt64(self.recordid)
end
function CGetRealtimeRecordReq:unmarshal(os)
  self.recordid = os:unmarshalInt64()
end
function CGetRealtimeRecordReq:sizepolicy(size)
  return size <= 65535
end
return CGetRealtimeRecordReq
