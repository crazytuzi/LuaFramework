local SQueryCatsFailed = class("SQueryCatsFailed")
SQueryCatsFailed.TYPEID = 12605712
SQueryCatsFailed.ERROR_NOT_EXIST = -1
function SQueryCatsFailed:ctor(target_roleid, catid, retcode)
  self.id = 12605712
  self.target_roleid = target_roleid or nil
  self.catid = catid or nil
  self.retcode = retcode or nil
end
function SQueryCatsFailed:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt64(self.catid)
  os:marshalInt32(self.retcode)
end
function SQueryCatsFailed:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.catid = os:unmarshalInt64()
  self.retcode = os:unmarshalInt32()
end
function SQueryCatsFailed:sizepolicy(size)
  return size <= 65535
end
return SQueryCatsFailed
