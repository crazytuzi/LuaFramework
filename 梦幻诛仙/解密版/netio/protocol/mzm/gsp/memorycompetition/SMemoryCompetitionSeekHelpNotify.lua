local SMemoryCompetitionSeekHelpNotify = class("SMemoryCompetitionSeekHelpNotify")
SMemoryCompetitionSeekHelpNotify.TYPEID = 12613127
function SMemoryCompetitionSeekHelpNotify:ctor(activity_cfg_id, seek_help_role_id)
  self.id = 12613127
  self.activity_cfg_id = activity_cfg_id or nil
  self.seek_help_role_id = seek_help_role_id or nil
end
function SMemoryCompetitionSeekHelpNotify:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.seek_help_role_id)
end
function SMemoryCompetitionSeekHelpNotify:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.seek_help_role_id = os:unmarshalInt64()
end
function SMemoryCompetitionSeekHelpNotify:sizepolicy(size)
  return size <= 65535
end
return SMemoryCompetitionSeekHelpNotify
