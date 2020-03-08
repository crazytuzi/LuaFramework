local SSyncRecordFightEnd = class("SSyncRecordFightEnd")
SSyncRecordFightEnd.TYPEID = 12594215
function SSyncRecordFightEnd:ctor(recordid, fight_end_content)
  self.id = 12594215
  self.recordid = recordid or nil
  self.fight_end_content = fight_end_content or nil
end
function SSyncRecordFightEnd:marshal(os)
  os:marshalInt64(self.recordid)
  os:marshalOctets(self.fight_end_content)
end
function SSyncRecordFightEnd:unmarshal(os)
  self.recordid = os:unmarshalInt64()
  self.fight_end_content = os:unmarshalOctets()
end
function SSyncRecordFightEnd:sizepolicy(size)
  return size <= 65535
end
return SSyncRecordFightEnd
