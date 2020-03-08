local SSyncTreasureHuntInfo = class("SSyncTreasureHuntInfo")
SSyncTreasureHuntInfo.TYPEID = 12633093
function SSyncTreasureHuntInfo:ctor(activity_cfg_id, process, total, left_seconds, chapter_cfg_id)
  self.id = 12633093
  self.activity_cfg_id = activity_cfg_id or nil
  self.process = process or nil
  self.total = total or nil
  self.left_seconds = left_seconds or nil
  self.chapter_cfg_id = chapter_cfg_id or nil
end
function SSyncTreasureHuntInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.process)
  os:marshalInt32(self.total)
  os:marshalInt32(self.left_seconds)
  os:marshalInt32(self.chapter_cfg_id)
end
function SSyncTreasureHuntInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.process = os:unmarshalInt32()
  self.total = os:unmarshalInt32()
  self.left_seconds = os:unmarshalInt32()
  self.chapter_cfg_id = os:unmarshalInt32()
end
function SSyncTreasureHuntInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncTreasureHuntInfo
