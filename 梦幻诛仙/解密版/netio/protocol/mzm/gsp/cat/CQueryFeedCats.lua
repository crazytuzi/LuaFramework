local CQueryFeedCats = class("CQueryFeedCats")
CQueryFeedCats.TYPEID = 12605720
function CQueryFeedCats:ctor(target_roleid, catid)
  self.id = 12605720
  self.target_roleid = target_roleid or nil
  self.catid = catid or nil
end
function CQueryFeedCats:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt64(self.catid)
end
function CQueryFeedCats:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.catid = os:unmarshalInt64()
end
function CQueryFeedCats:sizepolicy(size)
  return size <= 65535
end
return CQueryFeedCats
