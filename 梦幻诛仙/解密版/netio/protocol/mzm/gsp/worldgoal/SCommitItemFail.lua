local SCommitItemFail = class("SCommitItemFail")
SCommitItemFail.TYPEID = 12594436
SCommitItemFail.CAN_NOT_JOIN_ACTIVITY = 1
SCommitItemFail.COMMIT_TO_LIMIT = 2
SCommitItemFail.ACTIVITY_ITEM_FULL = 3
SCommitItemFail.NO_COMMIT_ITEM = 4
SCommitItemFail.COMMIT_AWARD_FAIL = 5
SCommitItemFail.CHECK_NPC_SERVICE_ERROR = 6
SCommitItemFail.SECTION_COMPLETE = 7
SCommitItemFail.SECTION_NOT_OPEN = 8
function SCommitItemFail:ctor(activity_cfg_id, res)
  self.id = 12594436
  self.activity_cfg_id = activity_cfg_id or nil
  self.res = res or nil
end
function SCommitItemFail:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.res)
end
function SCommitItemFail:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
end
function SCommitItemFail:sizepolicy(size)
  return size <= 65535
end
return SCommitItemFail
