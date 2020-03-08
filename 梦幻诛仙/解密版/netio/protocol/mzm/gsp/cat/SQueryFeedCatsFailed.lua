local SQueryFeedCatsFailed = class("SQueryFeedCatsFailed")
SQueryFeedCatsFailed.TYPEID = 12605719
SQueryFeedCatsFailed.ERROR_NOT_EXIST = -1
function SQueryFeedCatsFailed:ctor(target_roleid, catid, retcode)
  self.id = 12605719
  self.target_roleid = target_roleid or nil
  self.catid = catid or nil
  self.retcode = retcode or nil
end
function SQueryFeedCatsFailed:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt64(self.catid)
  os:marshalInt32(self.retcode)
end
function SQueryFeedCatsFailed:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.catid = os:unmarshalInt64()
  self.retcode = os:unmarshalInt32()
end
function SQueryFeedCatsFailed:sizepolicy(size)
  return size <= 65535
end
return SQueryFeedCatsFailed
