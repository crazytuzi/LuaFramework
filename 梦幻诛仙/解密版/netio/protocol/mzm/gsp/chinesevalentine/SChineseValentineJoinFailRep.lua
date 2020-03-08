local SChineseValentineJoinFailRep = class("SChineseValentineJoinFailRep")
SChineseValentineJoinFailRep.TYPEID = 12622082
SChineseValentineJoinFailRep.MEMBER_COUNT_ERROR = 1
SChineseValentineJoinFailRep.MEMBER_LEVEL_NOT_ENOUGH = 2
SChineseValentineJoinFailRep.ACTIVITY_CLOSED = 3
SChineseValentineJoinFailRep.NPC_SERVICE_NOT_AVAILABLE = 4
SChineseValentineJoinFailRep.NOT_NEARBY_NPC = 5
SChineseValentineJoinFailRep.TEAM_NOT_EXIST = 6
SChineseValentineJoinFailRep.IS_NOT_LEADER = 7
SChineseValentineJoinFailRep.TEAM_MEMBER_STATE_ERROR = 8
SChineseValentineJoinFailRep.TEAM_CHANGED = 9
SChineseValentineJoinFailRep.TEAM_MEMBER_AlREADY_IN_GAME = 10
function SChineseValentineJoinFailRep:ctor(code, activityId)
  self.id = 12622082
  self.code = code or nil
  self.activityId = activityId or nil
end
function SChineseValentineJoinFailRep:marshal(os)
  os:marshalInt32(self.code)
  os:marshalInt32(self.activityId)
end
function SChineseValentineJoinFailRep:unmarshal(os)
  self.code = os:unmarshalInt32()
  self.activityId = os:unmarshalInt32()
end
function SChineseValentineJoinFailRep:sizepolicy(size)
  return size <= 65535
end
return SChineseValentineJoinFailRep
