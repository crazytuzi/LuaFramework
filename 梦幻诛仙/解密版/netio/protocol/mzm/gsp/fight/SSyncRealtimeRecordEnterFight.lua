local SSyncRealtimeRecordEnterFight = class("SSyncRealtimeRecordEnterFight")
SSyncRealtimeRecordEnterFight.TYPEID = 12594219
function SSyncRealtimeRecordEnterFight:ctor(recordid, rounds, enter_fight_content, is_realtime)
  self.id = 12594219
  self.recordid = recordid or nil
  self.rounds = rounds or nil
  self.enter_fight_content = enter_fight_content or nil
  self.is_realtime = is_realtime or nil
end
function SSyncRealtimeRecordEnterFight:marshal(os)
  os:marshalInt64(self.recordid)
  os:marshalInt32(self.rounds)
  os:marshalOctets(self.enter_fight_content)
  os:marshalUInt8(self.is_realtime)
end
function SSyncRealtimeRecordEnterFight:unmarshal(os)
  self.recordid = os:unmarshalInt64()
  self.rounds = os:unmarshalInt32()
  self.enter_fight_content = os:unmarshalOctets()
  self.is_realtime = os:unmarshalUInt8()
end
function SSyncRealtimeRecordEnterFight:sizepolicy(size)
  return size <= 65535
end
return SSyncRealtimeRecordEnterFight
