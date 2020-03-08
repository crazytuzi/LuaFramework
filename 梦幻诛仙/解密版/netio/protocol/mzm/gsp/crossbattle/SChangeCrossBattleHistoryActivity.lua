local SChangeCrossBattleHistoryActivity = class("SChangeCrossBattleHistoryActivity")
SChangeCrossBattleHistoryActivity.TYPEID = 12617091
function SChangeCrossBattleHistoryActivity:ctor(session, activity_cfg_id)
  self.id = 12617091
  self.session = session or nil
  self.activity_cfg_id = activity_cfg_id or nil
end
function SChangeCrossBattleHistoryActivity:marshal(os)
  os:marshalInt32(self.session)
  os:marshalInt32(self.activity_cfg_id)
end
function SChangeCrossBattleHistoryActivity:unmarshal(os)
  self.session = os:unmarshalInt32()
  self.activity_cfg_id = os:unmarshalInt32()
end
function SChangeCrossBattleHistoryActivity:sizepolicy(size)
  return size <= 65535
end
return SChangeCrossBattleHistoryActivity
