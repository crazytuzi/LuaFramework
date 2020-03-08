local CQueryCats = class("CQueryCats")
CQueryCats.TYPEID = 12605710
function CQueryCats:ctor(target_roleid, catid)
  self.id = 12605710
  self.target_roleid = target_roleid or nil
  self.catid = catid or nil
end
function CQueryCats:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt64(self.catid)
end
function CQueryCats:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.catid = os:unmarshalInt64()
end
function CQueryCats:sizepolicy(size)
  return size <= 65535
end
return CQueryCats
