local SGetSignState = class("SGetSignState")
SGetSignState.TYPEID = 12589944
function SGetSignState:ctor(state)
  self.id = 12589944
  self.state = state or nil
end
function SGetSignState:marshal(os)
  os:marshalInt32(self.state)
end
function SGetSignState:unmarshal(os)
  self.state = os:unmarshalInt32()
end
function SGetSignState:sizepolicy(size)
  return size <= 65535
end
return SGetSignState
