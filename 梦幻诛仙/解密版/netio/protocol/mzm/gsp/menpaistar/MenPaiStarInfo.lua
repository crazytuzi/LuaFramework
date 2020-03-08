local OctetsStream = require("netio.OctetsStream")
local MenPaiStarInfo = class("MenPaiStarInfo")
function MenPaiStarInfo:ctor(campaign, today_campaign_num, last_campaign_time, vote, today_vote_num, last_vote_time, vote_num, world_canvass, gang_canvass)
  self.campaign = campaign or nil
  self.today_campaign_num = today_campaign_num or nil
  self.last_campaign_time = last_campaign_time or nil
  self.vote = vote or nil
  self.today_vote_num = today_vote_num or nil
  self.last_vote_time = last_vote_time or nil
  self.vote_num = vote_num or nil
  self.world_canvass = world_canvass or {}
  self.gang_canvass = gang_canvass or {}
end
function MenPaiStarInfo:marshal(os)
  os:marshalUInt8(self.campaign)
  os:marshalInt32(self.today_campaign_num)
  os:marshalInt32(self.last_campaign_time)
  os:marshalUInt8(self.vote)
  os:marshalInt32(self.today_vote_num)
  os:marshalInt32(self.last_vote_time)
  os:marshalInt32(self.vote_num)
  do
    local _size_ = 0
    for _, _ in pairs(self.world_canvass) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.world_canvass) do
      os:marshalInt64(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.gang_canvass) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.gang_canvass) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function MenPaiStarInfo:unmarshal(os)
  self.campaign = os:unmarshalUInt8()
  self.today_campaign_num = os:unmarshalInt32()
  self.last_campaign_time = os:unmarshalInt32()
  self.vote = os:unmarshalUInt8()
  self.today_vote_num = os:unmarshalInt32()
  self.last_vote_time = os:unmarshalInt32()
  self.vote_num = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.world_canvass[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.gang_canvass[k] = v
  end
end
return MenPaiStarInfo
