local SSyncRealtimeRecordRoundInfo = class("SSyncRealtimeRecordRoundInfo")
SSyncRealtimeRecordRoundInfo.TYPEID = 12594223
function SSyncRealtimeRecordRoundInfo:ctor(recordid, round)
  self.id = 12594223
  self.recordid = recordid or nil
  self.round = round or nil
end
function SSyncRealtimeRecordRoundInfo:marshal(os)
  os:marshalInt64(self.recordid)
  os:marshalInt32(self.round)
end
function SSyncRealtimeRecordRoundInfo:unmarshal(os)
  self.recordid = os:unmarshalInt64()
  self.round = os:unmarshalInt32()
end
function SSyncRealtimeRecordRoundInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncRealtimeRecordRoundInfo
