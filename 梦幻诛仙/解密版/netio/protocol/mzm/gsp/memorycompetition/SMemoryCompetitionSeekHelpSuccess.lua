local SMemoryCompetitionSeekHelpSuccess = class("SMemoryCompetitionSeekHelpSuccess")
SMemoryCompetitionSeekHelpSuccess.TYPEID = 12613131
function SMemoryCompetitionSeekHelpSuccess:ctor(activity_cfg_id, left_seek_help_times)
  self.id = 12613131
  self.activity_cfg_id = activity_cfg_id or nil
  self.left_seek_help_times = left_seek_help_times or nil
end
function SMemoryCompetitionSeekHelpSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.left_seek_help_times)
end
function SMemoryCompetitionSeekHelpSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.left_seek_help_times = os:unmarshalInt32()
end
function SMemoryCompetitionSeekHelpSuccess:sizepolicy(size)
  return size <= 65535
end
return SMemoryCompetitionSeekHelpSuccess
