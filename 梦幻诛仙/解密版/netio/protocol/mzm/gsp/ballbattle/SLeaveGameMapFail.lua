local SLeaveGameMapFail = class("SLeaveGameMapFail")
SLeaveGameMapFail.TYPEID = 12629255
SLeaveGameMapFail.NOT_IN_GAME_MAP = 1
SLeaveGameMapFail.GAME_NOT_FINISH_INIT = 2
function SLeaveGameMapFail:ctor(reason)
  self.id = 12629255
  self.reason = reason or nil
end
function SLeaveGameMapFail:marshal(os)
  os:marshalInt32(self.reason)
end
function SLeaveGameMapFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function SLeaveGameMapFail:sizepolicy(size)
  return size <= 65535
end
return SLeaveGameMapFail
