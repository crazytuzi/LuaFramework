local SAttendFetusEducationMusicFail = class("SAttendFetusEducationMusicFail")
SAttendFetusEducationMusicFail.TYPEID = 12609295
SAttendFetusEducationMusicFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendFetusEducationMusicFail.ROLE_STATUS_ERROR = -2
SAttendFetusEducationMusicFail.CHECK_NPC_SERVICE_ERROR = -3
SAttendFetusEducationMusicFail.HAVE_NO_HOMELAND = 1
SAttendFetusEducationMusicFail.NOT_GOT_MARRIED = 2
SAttendFetusEducationMusicFail.BREED_STATE_ERROR = 3
SAttendFetusEducationMusicFail.POINT_TO_UPPER_LIMIT = 4
SAttendFetusEducationMusicFail.CAN_NOT_JOIN_ACTIVITY = 5
SAttendFetusEducationMusicFail.OTHER_GAME_NOT_OVER = 6
function SAttendFetusEducationMusicFail:ctor(res)
  self.id = 12609295
  self.res = res or nil
end
function SAttendFetusEducationMusicFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendFetusEducationMusicFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendFetusEducationMusicFail:sizepolicy(size)
  return size <= 65535
end
return SAttendFetusEducationMusicFail
