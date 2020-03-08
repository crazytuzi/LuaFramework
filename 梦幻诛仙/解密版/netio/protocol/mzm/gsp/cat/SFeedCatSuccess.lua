local SFeedCatSuccess = class("SFeedCatSuccess")
SFeedCatSuccess.TYPEID = 12605715
function SFeedCatSuccess:ctor(target_roleid, catid)
  self.id = 12605715
  self.target_roleid = target_roleid or nil
  self.catid = catid or nil
end
function SFeedCatSuccess:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt64(self.catid)
end
function SFeedCatSuccess:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.catid = os:unmarshalInt64()
end
function SFeedCatSuccess:sizepolicy(size)
  return size <= 65535
end
return SFeedCatSuccess
