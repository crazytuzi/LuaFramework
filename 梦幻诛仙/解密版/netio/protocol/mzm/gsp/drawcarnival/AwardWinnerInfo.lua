local OctetsStream = require("netio.OctetsStream")
local AwardWinnerInfo = class("AwardWinnerInfo")
function AwardWinnerInfo:ctor(role_id, role_name, random_type_id, award_count)
  self.role_id = role_id or nil
  self.role_name = role_name or nil
  self.random_type_id = random_type_id or nil
  self.award_count = award_count or nil
end
function AwardWinnerInfo:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.random_type_id)
  os:marshalInt64(self.award_count)
end
function AwardWinnerInfo:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
  self.random_type_id = os:unmarshalInt32()
  self.award_count = os:unmarshalInt64()
end
return AwardWinnerInfo
