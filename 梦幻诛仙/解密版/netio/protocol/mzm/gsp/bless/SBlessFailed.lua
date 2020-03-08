local SBlessFailed = class("SBlessFailed")
SBlessFailed.TYPEID = 12614657
SBlessFailed.ERROR_ITEM_NOT_ENOUGH = -1
SBlessFailed.ERROR_BAG_FULL = -2
SBlessFailed.ERROR_MAX_NUM = -3
SBlessFailed.ERROR_CAN_NOT_JOIN_ACTIVITY = -4
function SBlessFailed:ctor(activity_cfgid, retcode)
  self.id = 12614657
  self.activity_cfgid = activity_cfgid or nil
  self.retcode = retcode or nil
end
function SBlessFailed:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.retcode)
end
function SBlessFailed:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SBlessFailed:sizepolicy(size)
  return size <= 65535
end
return SBlessFailed
