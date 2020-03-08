local SFeedCatFailed = class("SFeedCatFailed")
SFeedCatFailed.TYPEID = 12605709
SFeedCatFailed.ERROR_VIGOR_MAX = -1
SFeedCatFailed.ERROR_CAT_FEEDED_MAX = -2
SFeedCatFailed.ERROR_FEEDED_TOTAL_MAX = -3
SFeedCatFailed.ERROR_STATE_EXPLORE = -4
SFeedCatFailed.ERROR_CAT_HAVE_AWARD = -5
function SFeedCatFailed:ctor(target_roleid, catid, retcode)
  self.id = 12605709
  self.target_roleid = target_roleid or nil
  self.catid = catid or nil
  self.retcode = retcode or nil
end
function SFeedCatFailed:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt64(self.catid)
  os:marshalInt32(self.retcode)
end
function SFeedCatFailed:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.catid = os:unmarshalInt64()
  self.retcode = os:unmarshalInt32()
end
function SFeedCatFailed:sizepolicy(size)
  return size <= 65535
end
return SFeedCatFailed
