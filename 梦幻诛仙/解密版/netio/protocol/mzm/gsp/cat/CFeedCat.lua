local CFeedCat = class("CFeedCat")
CFeedCat.TYPEID = 12605698
function CFeedCat:ctor(target_roleid, catid)
  self.id = 12605698
  self.target_roleid = target_roleid or nil
  self.catid = catid or nil
end
function CFeedCat:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt64(self.catid)
end
function CFeedCat:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.catid = os:unmarshalInt64()
end
function CFeedCat:sizepolicy(size)
  return size <= 65535
end
return CFeedCat
