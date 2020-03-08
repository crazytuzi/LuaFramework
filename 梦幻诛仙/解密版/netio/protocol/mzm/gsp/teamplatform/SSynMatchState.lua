local SSynMatchState = class("SSynMatchState")
SSynMatchState.TYPEID = 12593666
SSynMatchState.ST__MATCH_ING = 1
SSynMatchState.ST__MATCH_CANCEL = 2
function SSynMatchState:ctor(matchState)
  self.id = 12593666
  self.matchState = matchState or nil
end
function SSynMatchState:marshal(os)
  os:marshalInt32(self.matchState)
end
function SSynMatchState:unmarshal(os)
  self.matchState = os:unmarshalInt32()
end
function SSynMatchState:sizepolicy(size)
  return size <= 65535
end
return SSynMatchState
