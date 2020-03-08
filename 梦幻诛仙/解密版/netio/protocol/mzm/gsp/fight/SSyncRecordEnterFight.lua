local SSyncRecordEnterFight = class("SSyncRecordEnterFight")
SSyncRecordEnterFight.TYPEID = 12594216
function SSyncRecordEnterFight:ctor(recordid, enter_fight_content)
  self.id = 12594216
  self.recordid = recordid or nil
  self.enter_fight_content = enter_fight_content or nil
end
function SSyncRecordEnterFight:marshal(os)
  os:marshalInt64(self.recordid)
  os:marshalOctets(self.enter_fight_content)
end
function SSyncRecordEnterFight:unmarshal(os)
  self.recordid = os:unmarshalInt64()
  self.enter_fight_content = os:unmarshalOctets()
end
function SSyncRecordEnterFight:sizepolicy(size)
  return size <= 65535
end
return SSyncRecordEnterFight
