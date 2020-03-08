local SQueryFeedCatsSuccess = class("SQueryFeedCatsSuccess")
SQueryFeedCatsSuccess.TYPEID = 12605718
function SQueryFeedCatsSuccess:ctor(target_roleid, catid, feeds)
  self.id = 12605718
  self.target_roleid = target_roleid or nil
  self.catid = catid or nil
  self.feeds = feeds or {}
end
function SQueryFeedCatsSuccess:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt64(self.catid)
  os:marshalCompactUInt32(table.getn(self.feeds))
  for _, v in ipairs(self.feeds) do
    v:marshal(os)
  end
end
function SQueryFeedCatsSuccess:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.catid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.cat.FeedInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.feeds, v)
  end
end
function SQueryFeedCatsSuccess:sizepolicy(size)
  return size <= 65535
end
return SQueryFeedCatsSuccess
