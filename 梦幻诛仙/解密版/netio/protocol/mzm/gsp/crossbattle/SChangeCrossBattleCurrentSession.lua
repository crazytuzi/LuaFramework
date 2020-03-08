local SChangeCrossBattleCurrentSession = class("SChangeCrossBattleCurrentSession")
SChangeCrossBattleCurrentSession.TYPEID = 12617092
function SChangeCrossBattleCurrentSession:ctor(session)
  self.id = 12617092
  self.session = session or nil
end
function SChangeCrossBattleCurrentSession:marshal(os)
  os:marshalInt32(self.session)
end
function SChangeCrossBattleCurrentSession:unmarshal(os)
  self.session = os:unmarshalInt32()
end
function SChangeCrossBattleCurrentSession:sizepolicy(size)
  return size <= 65535
end
return SChangeCrossBattleCurrentSession
