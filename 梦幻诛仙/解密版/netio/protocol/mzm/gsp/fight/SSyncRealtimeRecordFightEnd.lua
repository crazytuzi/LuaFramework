local SSyncRealtimeRecordFightEnd = class("SSyncRealtimeRecordFightEnd")
SSyncRealtimeRecordFightEnd.TYPEID = 12594218
function SSyncRealtimeRecordFightEnd:ctor(recordid, fight_end_content)
  self.id = 12594218
  self.recordid = recordid or nil
  self.fight_end_content = fight_end_content or nil
end
function SSyncRealtimeRecordFightEnd:marshal(os)
  os:marshalInt64(self.recordid)
  os:marshalOctets(self.fight_end_content)
end
function SSyncRealtimeRecordFightEnd:unmarshal(os)
  self.recordid = os:unmarshalInt64()
  self.fight_end_content = os:unmarshalOctets()
end
function SSyncRealtimeRecordFightEnd:sizepolicy(size)
  return size <= 65535
end
return SSyncRealtimeRecordFightEnd
