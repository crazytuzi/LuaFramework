local SFighterOnlineBrd = class("SFighterOnlineBrd")
SFighterOnlineBrd.TYPEID = 12594181
SFighterOnlineBrd.OFFLINE = 0
SFighterOnlineBrd.ONLINE = 1
function SFighterOnlineBrd:ctor(fighterid, status)
  self.id = 12594181
  self.fighterid = fighterid or nil
  self.status = status or nil
end
function SFighterOnlineBrd:marshal(os)
  os:marshalInt32(self.fighterid)
  os:marshalInt32(self.status)
end
function SFighterOnlineBrd:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.status = os:unmarshalInt32()
end
function SFighterOnlineBrd:sizepolicy(size)
  return size <= 65535
end
return SFighterOnlineBrd
