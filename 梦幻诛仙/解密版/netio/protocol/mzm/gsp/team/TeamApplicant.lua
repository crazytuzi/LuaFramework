local OctetsStream = require("netio.OctetsStream")
local TeamApplicant = class("TeamApplicant")
function TeamApplicant:ctor(applicant_id, applicant_name, applicant_level, applicant_menpai, applicant_gender, avatarId, avatarFrameid, recommender)
  self.applicant_id = applicant_id or nil
  self.applicant_name = applicant_name or nil
  self.applicant_level = applicant_level or nil
  self.applicant_menpai = applicant_menpai or nil
  self.applicant_gender = applicant_gender or nil
  self.avatarId = avatarId or nil
  self.avatarFrameid = avatarFrameid or nil
  self.recommender = recommender or nil
end
function TeamApplicant:marshal(os)
  os:marshalInt64(self.applicant_id)
  os:marshalString(self.applicant_name)
  os:marshalInt32(self.applicant_level)
  os:marshalInt32(self.applicant_menpai)
  os:marshalInt32(self.applicant_gender)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameid)
  os:marshalString(self.recommender)
end
function TeamApplicant:unmarshal(os)
  self.applicant_id = os:unmarshalInt64()
  self.applicant_name = os:unmarshalString()
  self.applicant_level = os:unmarshalInt32()
  self.applicant_menpai = os:unmarshalInt32()
  self.applicant_gender = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameid = os:unmarshalInt32()
  self.recommender = os:unmarshalString()
end
return TeamApplicant
