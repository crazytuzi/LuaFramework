local CQuitRealtimeRecordReq = class("CQuitRealtimeRecordReq")
CQuitRealtimeRecordReq.TYPEID = 12594222
function CQuitRealtimeRecordReq:ctor()
  self.id = 12594222
end
function CQuitRealtimeRecordReq:marshal(os)
end
function CQuitRealtimeRecordReq:unmarshal(os)
end
function CQuitRealtimeRecordReq:sizepolicy(size)
  return size <= 65535
end
return CQuitRealtimeRecordReq
