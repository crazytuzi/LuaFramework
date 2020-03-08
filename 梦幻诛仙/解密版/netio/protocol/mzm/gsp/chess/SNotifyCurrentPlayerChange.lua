local SNotifyCurrentPlayerChange = class("SNotifyCurrentPlayerChange")
SNotifyCurrentPlayerChange.TYPEID = 12619040
SNotifyCurrentPlayerChange.SIDE_RED = 1
SNotifyCurrentPlayerChange.SIDE_BLUE = 2
function SNotifyCurrentPlayerChange:ctor(current_player)
  self.id = 12619040
  self.current_player = current_player or nil
end
function SNotifyCurrentPlayerChange:marshal(os)
  os:marshalInt32(self.current_player)
end
function SNotifyCurrentPlayerChange:unmarshal(os)
  self.current_player = os:unmarshalInt32()
end
function SNotifyCurrentPlayerChange:sizepolicy(size)
  return size <= 65535
end
return SNotifyCurrentPlayerChange
