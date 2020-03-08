local OctetsStream = require("netio.OctetsStream")
local FightRecordData = class("FightRecordData")
FightRecordData.ATTACK = 0
FightRecordData.DEFEND = 1
function FightRecordData:ctor(recordid, record_type, is_win, old_rank, new_rank, fight_time, roleid, avatar, avatar_frame, name, occupation, gender)
  self.recordid = recordid or nil
  self.record_type = record_type or nil
  self.is_win = is_win or nil
  self.old_rank = old_rank or nil
  self.new_rank = new_rank or nil
  self.fight_time = fight_time or nil
  self.roleid = roleid or nil
  self.avatar = avatar or nil
  self.avatar_frame = avatar_frame or nil
  self.name = name or nil
  self.occupation = occupation or nil
  self.gender = gender or nil
end
function FightRecordData:marshal(os)
  os:marshalInt64(self.recordid)
  os:marshalInt32(self.record_type)
  os:marshalInt32(self.is_win)
  os:marshalInt32(self.old_rank)
  os:marshalInt32(self.new_rank)
  os:marshalInt32(self.fight_time)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.avatar)
  os:marshalInt32(self.avatar_frame)
  os:marshalOctets(self.name)
  os:marshalInt32(self.occupation)
  os:marshalUInt8(self.gender)
end
function FightRecordData:unmarshal(os)
  self.recordid = os:unmarshalInt64()
  self.record_type = os:unmarshalInt32()
  self.is_win = os:unmarshalInt32()
  self.old_rank = os:unmarshalInt32()
  self.new_rank = os:unmarshalInt32()
  self.fight_time = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.avatar = os:unmarshalInt32()
  self.avatar_frame = os:unmarshalInt32()
  self.name = os:unmarshalOctets()
  self.occupation = os:unmarshalInt32()
  self.gender = os:unmarshalUInt8()
end
return FightRecordData
