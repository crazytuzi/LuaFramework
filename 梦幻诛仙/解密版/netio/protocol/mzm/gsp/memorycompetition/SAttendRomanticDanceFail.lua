local SAttendRomanticDanceFail = class("SAttendRomanticDanceFail")
SAttendRomanticDanceFail.TYPEID = 12613137
SAttendRomanticDanceFail.TEAM_NOT_EXIST = 1
SAttendRomanticDanceFail.ONLY_TEAM_LEADER_CAN_OPEN_GAME = 2
SAttendRomanticDanceFail.TEAM_SIZE_NOT_TWO = 3
SAttendRomanticDanceFail.TEAM_MEMBER_NOT_NORMAL = 4
SAttendRomanticDanceFail.TEAM_LEADER_ALEARDY_IN_GAME = 5
SAttendRomanticDanceFail.TEAM_MEMBER_ALEARDY_IN_GAME = 6
SAttendRomanticDanceFail.ROMANTIC_DANCE_NOT_AWARD = 7
SAttendRomanticDanceFail.ROMANTIC_DANCE_MEMORY_CFG_NOT_EXIST = 8
SAttendRomanticDanceFail.ROMANTIC_DANCE_NPC_SERVICE_CHECK_FAIL = 9
SAttendRomanticDanceFail.MEMORY_CFG_NOT_EXIST = 10
SAttendRomanticDanceFail.ROMANTIC_DANCE_ACTIVITY_CAN_NOT_JOIN = 11
SAttendRomanticDanceFail.HARD_RANK_CFG_NOT_EXIST = 12
SAttendRomanticDanceFail.LEADER_STATUS_WERONG = 13
SAttendRomanticDanceFail.MEMBER_STATUS_WRONG = 14
function SAttendRomanticDanceFail:ctor(result)
  self.id = 12613137
  self.result = result or nil
end
function SAttendRomanticDanceFail:marshal(os)
  os:marshalInt32(self.result)
end
function SAttendRomanticDanceFail:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SAttendRomanticDanceFail:sizepolicy(size)
  return size <= 65535
end
return SAttendRomanticDanceFail
