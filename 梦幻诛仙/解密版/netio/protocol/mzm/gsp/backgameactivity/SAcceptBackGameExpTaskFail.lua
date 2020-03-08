local SAcceptBackGameExpTaskFail = class("SAcceptBackGameExpTaskFail")
SAcceptBackGameExpTaskFail.TYPEID = 12620561
SAcceptBackGameExpTaskFail.NOT_IN_BACK_GAME_ACTIVITY = -1
SAcceptBackGameExpTaskFail.NOT_IN_TEAM = -2
SAcceptBackGameExpTaskFail.NOT_TEAM_LEADER = -3
SAcceptBackGameExpTaskFail.MENBER_COUNT_NOT_ENOUGH = -4
SAcceptBackGameExpTaskFail.ALREADY_ACCEPT_TASK = -5
SAcceptBackGameExpTaskFail.ALREADY_GET_TASK_AWARD = -6
function SAcceptBackGameExpTaskFail:ctor(error_code)
  self.id = 12620561
  self.error_code = error_code or nil
end
function SAcceptBackGameExpTaskFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SAcceptBackGameExpTaskFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SAcceptBackGameExpTaskFail:sizepolicy(size)
  return size <= 65535
end
return SAcceptBackGameExpTaskFail
