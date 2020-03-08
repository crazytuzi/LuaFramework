local OctetsStream = require("netio.OctetsStream")
local PetArenaInfo = class("PetArenaInfo")
function PetArenaInfo:ctor(rank, point, today_point, challenge_count, buy_count, refresh_time)
  self.rank = rank or nil
  self.point = point or nil
  self.today_point = today_point or nil
  self.challenge_count = challenge_count or nil
  self.buy_count = buy_count or nil
  self.refresh_time = refresh_time or nil
end
function PetArenaInfo:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.point)
  os:marshalInt32(self.today_point)
  os:marshalInt32(self.challenge_count)
  os:marshalInt32(self.buy_count)
  os:marshalInt32(self.refresh_time)
end
function PetArenaInfo:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
  self.today_point = os:unmarshalInt32()
  self.challenge_count = os:unmarshalInt32()
  self.buy_count = os:unmarshalInt32()
  self.refresh_time = os:unmarshalInt32()
end
return PetArenaInfo
