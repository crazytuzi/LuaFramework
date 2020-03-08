local OctetsStream = require("netio.OctetsStream")
local KeJuState = class("KeJuState")
KeJuState.XIANGSHI = 1
KeJuState.HUISHI = 2
KeJuState.DIANSHI = 3
KeJuState.NOT_START = 4
KeJuState.START = 5
KeJuState.END = 6
KeJuState.CAN_NOT_ACCESS = 7
function KeJuState:ctor(stateType, state)
  self.stateType = stateType or nil
  self.state = state or nil
end
function KeJuState:marshal(os)
  os:marshalInt32(self.stateType)
  os:marshalInt32(self.state)
end
function KeJuState:unmarshal(os)
  self.stateType = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
end
return KeJuState
