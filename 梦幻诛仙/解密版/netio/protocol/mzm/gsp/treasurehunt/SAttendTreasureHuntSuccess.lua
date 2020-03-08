local SAttendTreasureHuntSuccess = class("SAttendTreasureHuntSuccess")
SAttendTreasureHuntSuccess.TYPEID = 12633098
function SAttendTreasureHuntSuccess:ctor(activity_cfg_id, total, left_seconds, chapter_cfg_id)
  self.id = 12633098
  self.activity_cfg_id = activity_cfg_id or nil
  self.total = total or nil
  self.left_seconds = left_seconds or nil
  self.chapter_cfg_id = chapter_cfg_id or nil
end
function SAttendTreasureHuntSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.total)
  os:marshalInt32(self.left_seconds)
  os:marshalInt32(self.chapter_cfg_id)
end
function SAttendTreasureHuntSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.total = os:unmarshalInt32()
  self.left_seconds = os:unmarshalInt32()
  self.chapter_cfg_id = os:unmarshalInt32()
end
function SAttendTreasureHuntSuccess:sizepolicy(size)
  return size <= 65535
end
return SAttendTreasureHuntSuccess
