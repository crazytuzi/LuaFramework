local OctetsStream = require("netio.OctetsStream")
local PetArenaChartData = class("PetArenaChartData")
function PetArenaChartData:ctor(rank, roleid, name, win_num, lose_num, defend_win_num, defend_lose_num)
  self.rank = rank or nil
  self.roleid = roleid or nil
  self.name = name or nil
  self.win_num = win_num or nil
  self.lose_num = lose_num or nil
  self.defend_win_num = defend_win_num or nil
  self.defend_lose_num = defend_lose_num or nil
end
function PetArenaChartData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.name)
  os:marshalInt32(self.win_num)
  os:marshalInt32(self.lose_num)
  os:marshalInt32(self.defend_win_num)
  os:marshalInt32(self.defend_lose_num)
end
function PetArenaChartData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.win_num = os:unmarshalInt32()
  self.lose_num = os:unmarshalInt32()
  self.defend_win_num = os:unmarshalInt32()
  self.defend_lose_num = os:unmarshalInt32()
end
return PetArenaChartData
