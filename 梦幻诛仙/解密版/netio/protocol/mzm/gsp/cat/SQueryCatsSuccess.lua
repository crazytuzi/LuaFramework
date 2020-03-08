local CatInfo = require("netio.protocol.mzm.gsp.cat.CatInfo")
local SQueryCatsSuccess = class("SQueryCatsSuccess")
SQueryCatsSuccess.TYPEID = 12605700
function SQueryCatsSuccess:ctor(target_roleid, cat_info, feed_num)
  self.id = 12605700
  self.target_roleid = target_roleid or nil
  self.cat_info = cat_info or CatInfo.new()
  self.feed_num = feed_num or nil
end
function SQueryCatsSuccess:marshal(os)
  os:marshalInt64(self.target_roleid)
  self.cat_info:marshal(os)
  os:marshalInt32(self.feed_num)
end
function SQueryCatsSuccess:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.cat_info = CatInfo.new()
  self.cat_info:unmarshal(os)
  self.feed_num = os:unmarshalInt32()
end
function SQueryCatsSuccess:sizepolicy(size)
  return size <= 65535
end
return SQueryCatsSuccess
