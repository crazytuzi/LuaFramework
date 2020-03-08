local SIdipUnbanPlay = class("SIdipUnbanPlay")
SIdipUnbanPlay.TYPEID = 12601092
function SIdipUnbanPlay:ctor(playType)
  self.id = 12601092
  self.playType = playType or nil
end
function SIdipUnbanPlay:marshal(os)
  os:marshalInt32(self.playType)
end
function SIdipUnbanPlay:unmarshal(os)
  self.playType = os:unmarshalInt32()
end
function SIdipUnbanPlay:sizepolicy(size)
  return size <= 65535
end
return SIdipUnbanPlay
