local SSyncRealtimeRecordRoundPlay = class("SSyncRealtimeRecordRoundPlay")
SSyncRealtimeRecordRoundPlay.TYPEID = 12594220
function SSyncRealtimeRecordRoundPlay:ctor(recordid, round, round_play_content)
  self.id = 12594220
  self.recordid = recordid or nil
  self.round = round or nil
  self.round_play_content = round_play_content or nil
end
function SSyncRealtimeRecordRoundPlay:marshal(os)
  os:marshalInt64(self.recordid)
  os:marshalInt32(self.round)
  os:marshalOctets(self.round_play_content)
end
function SSyncRealtimeRecordRoundPlay:unmarshal(os)
  self.recordid = os:unmarshalInt64()
  self.round = os:unmarshalInt32()
  self.round_play_content = os:unmarshalOctets()
end
function SSyncRealtimeRecordRoundPlay:sizepolicy(size)
  return size <= 65535
end
return SSyncRealtimeRecordRoundPlay
