local PetArenaInfo = require("netio.protocol.mzm.gsp.petarena.PetArenaInfo")
local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SStartFightSuccess = class("SStartFightSuccess")
SStartFightSuccess.TYPEID = 12628239
function SStartFightSuccess:ctor(target_roleid, rank, teamid, pet_arena_info, award_info, add_point)
  self.id = 12628239
  self.target_roleid = target_roleid or nil
  self.rank = rank or nil
  self.teamid = teamid or nil
  self.pet_arena_info = pet_arena_info or PetArenaInfo.new()
  self.award_info = award_info or AwardBean.new()
  self.add_point = add_point or nil
end
function SStartFightSuccess:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.teamid)
  self.pet_arena_info:marshal(os)
  self.award_info:marshal(os)
  os:marshalInt32(self.add_point)
end
function SStartFightSuccess:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.teamid = os:unmarshalInt32()
  self.pet_arena_info = PetArenaInfo.new()
  self.pet_arena_info:unmarshal(os)
  self.award_info = AwardBean.new()
  self.award_info:unmarshal(os)
  self.add_point = os:unmarshalInt32()
end
function SStartFightSuccess:sizepolicy(size)
  return size <= 65535
end
return SStartFightSuccess
