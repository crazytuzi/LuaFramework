local SEnterCrossBattleSelectionMapSuccess = class("SEnterCrossBattleSelectionMapSuccess")
SEnterCrossBattleSelectionMapSuccess.TYPEID = 12616993
function SEnterCrossBattleSelectionMapSuccess:ctor(left_seconds)
  self.id = 12616993
  self.left_seconds = left_seconds or nil
end
function SEnterCrossBattleSelectionMapSuccess:marshal(os)
  os:marshalInt64(self.left_seconds)
end
function SEnterCrossBattleSelectionMapSuccess:unmarshal(os)
  self.left_seconds = os:unmarshalInt64()
end
function SEnterCrossBattleSelectionMapSuccess:sizepolicy(size)
  return size <= 65535
end
return SEnterCrossBattleSelectionMapSuccess
