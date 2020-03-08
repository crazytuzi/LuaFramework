local OctetsStream = require("netio.OctetsStream")
local AdultStageInfo = class("AdultStageInfo")
function AdultStageInfo:ctor(animal_cfgid, last_mate_time, award_cfgid, birth_time)
  self.animal_cfgid = animal_cfgid or nil
  self.last_mate_time = last_mate_time or nil
  self.award_cfgid = award_cfgid or nil
  self.birth_time = birth_time or nil
end
function AdultStageInfo:marshal(os)
  os:marshalInt32(self.animal_cfgid)
  os:marshalInt32(self.last_mate_time)
  os:marshalInt32(self.award_cfgid)
  os:marshalInt32(self.birth_time)
end
function AdultStageInfo:unmarshal(os)
  self.animal_cfgid = os:unmarshalInt32()
  self.last_mate_time = os:unmarshalInt32()
  self.award_cfgid = os:unmarshalInt32()
  self.birth_time = os:unmarshalInt32()
end
return AdultStageInfo
