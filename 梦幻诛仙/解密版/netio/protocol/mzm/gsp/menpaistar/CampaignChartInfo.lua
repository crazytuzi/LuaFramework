local OctetsStream = require("netio.OctetsStream")
local VoteAwardInfo = require("netio.protocol.mzm.gsp.menpaistar.VoteAwardInfo")
local CampaignChartInfo = class("CampaignChartInfo")
function CampaignChartInfo:ctor(roleid, role_name, occupationid, rank, point, vote_award_info)
  self.roleid = roleid or nil
  self.role_name = role_name or nil
  self.occupationid = occupationid or nil
  self.rank = rank or nil
  self.point = point or nil
  self.vote_award_info = vote_award_info or VoteAwardInfo.new()
end
function CampaignChartInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.occupationid)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.point)
  self.vote_award_info:marshal(os)
end
function CampaignChartInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
  self.occupationid = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
  self.vote_award_info = VoteAwardInfo.new()
  self.vote_award_info:unmarshal(os)
end
return CampaignChartInfo
